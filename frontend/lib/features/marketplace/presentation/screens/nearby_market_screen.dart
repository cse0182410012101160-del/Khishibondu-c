import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  String? _userDivision;
  bool _isLoading = true;

  static const Map<String, LatLng> _centers = {
    'Dhaka': LatLng(23.8103, 90.4125),
    'Chattogram': LatLng(22.3356, 91.8332),
    'Rajshahi': LatLng(24.3745, 88.6011),
    'Rangpur': LatLng(25.7558, 89.2469),
    'Khulna': LatLng(22.8456, 89.5403),
    'Barishal': LatLng(22.7010, 90.3535),
    'Sylhet': LatLng(24.8949, 91.8687),
    'Mymensingh': LatLng(24.7531, 90.4062),
  };

  @override
  void initState() {
    super.initState();
    _detect();
  }

  Future<void> _detect() async {
    final result = await LocationService.instance.getLocationWithDivision();
    if (mounted) {
      setState(() {
        _userDivision = result['division'] as String?;
        _isLoading = false;
      });
    }
  }

  void _openLots() {
    final division = _userDivision;
    if (division == null) return;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CropListScreen(
              currentUser: widget.currentUser, initialDivision: division),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final position = _centers[_userDivision] ?? const LatLng(23.6850, 90.3563);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('marketplace'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  options: MapOptions(initialCenter: position, initialZoom: 7),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.agrobridge.app',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: position,
                        width: 52,
                        height: 52,
                        child: GestureDetector(
                          onTap: _openLots,
                          child: const Icon(Icons.location_on,
                              color: AppColors.primary, size: 48),
                        ),
                      ),
                    ]),
                  ],
                ),
                if (_userDivision != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Card(
                      color: AppColors.primary.withValues(alpha: 0.95),
                      child: ListTile(
                        leading: const Icon(Icons.location_on,
                            color: AppColors.secondary),
                        title: Text(
                            loc
                                .translate('mapDetected')
                                .replaceAll('{division}', _userDivision!),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(loc.translate('mapHint'),
                            style: const TextStyle(color: Colors.white70)),
                        trailing: ElevatedButton.icon(
                          onPressed: _openLots,
                          icon: const Icon(Icons.list, size: 18),
                          label: Text(loc.translate('viewLots'),
                              style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
