import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/geo/location_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'crop_list_screen.dart';

class NearbyMarketScreen extends StatefulWidget {
  final UserEntity currentUser;
  const NearbyMarketScreen({super.key, required this.currentUser});
  @override
  State<NearbyMarketScreen> createState() => _NearbyMarketScreenState();
}

class _NearbyMarketScreenState extends State<NearbyMarketScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  String? _userDivision;
  bool _isLoading = true;

  static const Map<String, LatLng> _centers = {
    'Dhaka': LatLng(23.8103, 90.4125), 'Chattogram': LatLng(22.3356, 91.8332),
    'Rajshahi': LatLng(24.3745, 88.6011), 'Rangpur': LatLng(25.7558, 89.2469),
    'Khulna': LatLng(22.8456, 89.5403), 'Barishal': LatLng(22.7010, 90.3535),
    'Sylhet': LatLng(24.8949, 91.8687), 'Mymensingh': LatLng(24.7531, 90.4062),
  };
  static const Map<String, int> _counts = {
    'Dhaka': 24, 'Chattogram': 18, 'Rajshahi': 32, 'Rangpur': 21,
    'Khulna': 15, 'Barishal': 12, 'Sylhet': 14, 'Mymensingh': 16,
  };

  @override
  void initState() {
    super.initState();
    _detect();
    _buildMarkers();
  }

  Future<void> _detect() async {
    final r = await LocationService.instance.getLocationWithDivision();
    if (mounted) setState(() { _userDivision = r['division'] as String?; _isLoading = false; });
  }

  void _buildMarkers() {
    _markers.clear();
    _centers.forEach((div, pos) {
      final isUser = div == _userDivision;
      _markers.add(Marker(
        markerId: MarkerId(div), position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isUser ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: div,
          snippet: '${_counts[div]} active lots${isUser ? ' • your division' : ''}'),
        onTap: () {
          _controller.future.then((c) => c.animateCamera(
            CameraUpdate.newLatLngZoom(pos, 7)));
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => CropListScreen(
              currentUser: widget.currentUser, initialDivision: div)));
        },
      ));
    });
    setState(() {});
  }

  void _goMyLocation() async {
    final pos = _userDivision != null ? _centers[_userDivision] : null;
    if (pos == null) return;
    final c = await _controller.future;
    c.animateCamera(CameraUpdate.newLatLngZoom(pos, 7));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final initPos = _userDivision != null ? _centers[_userDivision]! : const LatLng(23.6850, 90.3563);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('marketplace')),
        actions: [_userDivision != null ? IconButton(
          icon: const Icon(Icons.my_location),
          tooltip: 'Center on your division', onPressed: _goMyLocation) : const SizedBox()]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Stack(
        children: [
          GoogleMap(initialCameraPosition: CameraPosition(target: initPos, zoom: 6.5),
            markers: _markers, myLocationEnabled: true,
            myLocationButtonEnabled: false, zoomControlsEnabled: true,
            onMapCreated: (c) => _controller.complete(c)),
          if (_userDivision != null)
            Positioned(top: 12, left: 12, right: 12, child: Card(
              color: AppColors.primary.withValues(alpha: 0.95),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.secondary),
                title: Text('Detected: $_userDivision',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap a division to browse harvest lots',
                  style: TextStyle(color: Colors.white70)),
                trailing: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CropListScreen(
                      currentUser: widget.currentUser, initialDivision: _userDivision))),
                  icon: const Icon(Icons.list, size: 18),
                  label: const Text('View lots', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6))),
              ),
            )),
        ],
      ),
    );
  }
}
