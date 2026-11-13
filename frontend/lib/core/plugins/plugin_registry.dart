import 'package:flutter/material.dart';

/// Contract that every drop-in feature module must implement.
abstract class FeaturePlugin {
  String get id;
  String get title;
  String get titleBn;
  String get description;
  String get version;
  IconData get icon;
  List<String> get enabledRoles; // ['farmer', 'buyer', 'ngo', 'admin']

  /// Builds the entry widget/screen for this module
  Widget buildScreen(BuildContext context);

  /// Optional banner or card widget to appear on dashboards
  Widget? buildDashboardCard(BuildContext context) => null;

  /// Lifecycle callback when plugin is initialized
  Future<void> onInitialize() async {}
}

/// Central Extensible Registry for all Agro-Bridge Pluggable Modules
class PluginRegistry {
  static final PluginRegistry _instance = PluginRegistry._internal();
  factory PluginRegistry() => _instance;
  PluginRegistry._internal();

  final Map<String, FeaturePlugin> _plugins = {};
  final Map<String, bool> _activeFlags = {};

  /// Registers a new plugin into the runtime
  void register(FeaturePlugin plugin, {bool defaultActive = true}) {
    _plugins[plugin.id] = plugin;
    _activeFlags[plugin.id] = defaultActive;
    plugin.onInitialize();
  }

  /// Toggle feature flag
  void setPluginActive(String id, bool isActive) {
    if (_plugins.containsKey(id)) {
      _activeFlags[id] = isActive;
    }
  }

  bool isPluginActive(String id) {
    return _activeFlags[id] ?? false;
  }

  /// Get all registered plugins
  List<FeaturePlugin> getAllPlugins() {
    return _plugins.values.toList();
  }

  /// Get active plugins available for a given user role
  List<FeaturePlugin> getPluginsForRole(String role) {
    return _plugins.values
        .where((p) => (_activeFlags[p.id] ?? false) && p.enabledRoles.contains(role))
        .toList();
  }

  FeaturePlugin? getPlugin(String id) => _plugins[id];
}

