import 'package:flutter/material.dart';
import 'package:agro_bridge/core/di/injection.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import '../../../phase2/data/phase2_api.dart';

class MfiPortfolioScreen extends StatefulWidget {
  const MfiPortfolioScreen({super.key});

  @override
  State<MfiPortfolioScreen> createState() => _MfiPortfolioScreenState();
}

class _MfiPortfolioScreenState extends State<MfiPortfolioScreen> {
  Map<String, dynamic>? _portfolio;
  String? _error;

  Phase2Api get _api => Phase2Api(sl<ApiClient>());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await _api.getMfiPortfolio();
      if (mounted) {
        setState(() => _portfolio =
            Map<String, dynamic>.from(response['portfolio'] as Map));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            AppLocalizations.of(context).translate('mfiPortfolioUnavailable'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final portfolio = _portfolio;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('mfiPortfolioTitle'))),
      body: _error != null
          ? Center(child: Text(_error!))
          : portfolio == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _card(
                          loc.translate('applicantsByDistrict'),
                          Icons.location_city,
                          (portfolio['applicantsByDistrict'] as List? ?? [])
                              .map((item) =>
                                  '${item['district']}: ${item['applicants']}')
                              .join('\n')),
                      _card(
                          loc.translate('scoreBuckets'),
                          Icons.bar_chart,
                          (portfolio['scoreBuckets'] as List? ?? [])
                              .map((item) =>
                                  '${item['bucket']}: ${item['applicants']}')
                              .join('\n')),
                      _card(
                          loc.translate('repaymentRate'),
                          Icons.payments_outlined,
                          '${((portfolio['repaymentRate'] as num? ?? 0) * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
    );
  }

  Widget _card(String title, IconData icon, String value) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Icon(icon),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(value)
                ])),
          ]),
        ),
      );
}
