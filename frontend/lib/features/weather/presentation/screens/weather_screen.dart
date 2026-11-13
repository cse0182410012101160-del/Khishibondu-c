import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/weather_bloc.dart';
import '../widgets/cyclone_alert_banner.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _selectedDivision = 'Rajshahi';

  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(FetchWeatherEvent(division: _selectedDivision));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('weather'))),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WeatherErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is WeatherLoadedState) {
            final w = state.weather;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Division Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDivision,
                          isExpanded: true,
                          items: AppConstants.divisions
                              .where((d) => d != 'All')
                              .map((d) => DropdownMenuItem(value: d, child: Text('$d Division Weather & Station')))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedDivision = val);
                              context.read<WeatherBloc>().add(FetchWeatherEvent(division: val));
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Severe Cyclone / Flood Banner if active
                  CycloneAlertBanner(
                    isFloodAlert: w.floodAlert,
                    isCycloneAlert: w.cycloneAlert,
                    advisoryBn: w.advisoryBn,
                  ),

                  // Weather Main Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${w.district}, ${w.division}',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(w.conditionBn, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                            const Icon(Icons.wb_sunny_outlined, color: Colors.amberAccent, size: 48),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '${w.temperatureC.toStringAsFixed(1)}°C',
                              style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Risk Level: ${w.riskLevel}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem('Humidity', '${w.humidityPct}%', Icons.water_drop_outlined),
                            _statItem('Wind', '${w.windSpeedKmh} km/h', Icons.air),
                            _statItem('Rainfall', '${w.rainfallForecastMm} mm', Icons.umbrella_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Agro-Advisory Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.tips_and_updates, color: AppColors.secondary, size: 22),
                              SizedBox(width: 8),
                              Text('Agricultural Spray & Field Advisory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('বাংলা পরামর্শ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(w.advisoryBn, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary)),
                          const Divider(height: 20),
                          const Text('English Advisory:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(w.advisoryEn, style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

