import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

enum PendingRequestType { listing, bid }

class OfflineRequestQueue {
  OfflineRequestQueue() {
    _isWeb = kIsWeb;
  }

  Database? _database;
  bool _isWeb = false;

  // In-memory fallback used on Flutter Web, where sqflite has no browser
  // database factory. It mirrors the SQLite `pending_requests` schema
  // (id, type, path, payload, created_at) so the rest of the API behaves
  // identically across platforms.
  final List<Map<String, dynamic>> _memoryQueue = [];
  int _memoryNextId = 1;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Future<void> Function(
          String path, Map<String, dynamic> payload, PendingRequestType type)?
      _sender;

  Future<Database> get _db async {
    if (_isWeb) {
      throw UnsupportedError(
          'SQLite is unavailable on Flutter Web; use the in-memory queue.');
    }
    if (_database != null) return _database!;
    final path = '${await getDatabasesPath()}/agro_bridge_offline.db';
    _database =
        await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE pending_requests (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          path TEXT NOT NULL,
          payload TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
    });
    return _database!;
  }

  Future<void> initialize(
      {Future<void> Function(String path, Map<String, dynamic> payload,
              PendingRequestType type)?
          sender}) async {
    // Do NOT open the SQLite database on web (throws); only native targets do.
    if (!_isWeb) {
      await _db;
    }
    _sender = sender;
    _connectivitySubscription ??=
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none) &&
          _sender != null) {
        unawaited(flush(_sender!));
      }
    });
  }

  Future<void> enqueueListing(Map<String, dynamic> payload) =>
      _enqueue(PendingRequestType.listing, '/marketplace/crops', payload);

  Future<void> enqueueBid(String cropId, Map<String, dynamic> payload) =>
      _enqueue(
          PendingRequestType.bid, '/marketplace/crops/$cropId/bids', payload);

  Future<void> _enqueue(PendingRequestType type, String path,
      Map<String, dynamic> payload) async {
    final row = <String, dynamic>{
      'type': type.name,
      'path': path,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    if (_isWeb) {
      row['id'] = _memoryNextId++;
      _memoryQueue.add(row);
      return;
    }

    final db = await _db;
    row['id'] = await db.insert('pending_requests', row);
  }

  Future<int> get pendingCount async {
    if (_isWeb) {
      return _memoryQueue.length;
    }
    return Sqflite.firstIntValue(await (await _db)
            .rawQuery('SELECT COUNT(*) FROM pending_requests')) ??
        0;
  }

  Future<void> flush(
      Future<void> Function(String path, Map<String, dynamic> payload,
              PendingRequestType type)
          send) async {
    // Native: query SQLite ordered by created_at ascending.
    // Web: snapshot the in-memory list and sort defensively so ordering is
    // deterministic (the list is already append-only, but sorting matches the
    // SQLite `orderBy: 'created_at ASC'` behaviour exactly).
    List<Map<String, dynamic>> rows;
    if (_isWeb) {
      rows = _memoryQueue.map((r) => Map<String, dynamic>.from(r)).toList();
    } else {
      final db = await _db;
      rows = await db.query('pending_requests', orderBy: 'created_at ASC');
    }

    if (_isWeb) {
      rows.sort((a, b) =>
          (a['created_at'] as int).compareTo(b['created_at'] as int));
    }

    for (final row in rows) {
      final id = row['id'];
      try {
        await send(row['path'] as String, jsonDecode(row['payload'] as String),
            PendingRequestType.values.byName(row['type'] as String));
      } catch (_) {
        // Stop flushing on the first failure so a transient error does not
        // block older pending requests on the next attempt.
        break;
      }

      // Remove only after the send succeeds (identical to the native path,
      // which deletes from SQLite after the send completes).
      if (_isWeb) {
        _memoryQueue.removeWhere((r) => r['id'] == id);
      } else {
        final db = await _db;
        await db.delete('pending_requests',
            where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  Future<void> dispose() async => _connectivitySubscription?.cancel();
}

class PendingSyncBadge extends StatelessWidget {
  final OfflineRequestQueue queue;

  const PendingSyncBadge({super.key, required this.queue});

  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
        future: queue.pendingCount,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          if (count == 0) return const SizedBox.shrink();
          return Chip(
            avatar: const Icon(Icons.sync_problem, size: 16),
            label: Text('$count pending sync'),
            visualDensity: VisualDensity.compact,
          );
        },
      );
}
