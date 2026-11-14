import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/traceability_bloc.dart';

class BatchQrViewScreen extends StatefulWidget {
  final String batchQrCode;
  const BatchQrViewScreen({super.key, required this.batchQrCode});

  @override
  State<BatchQrViewScreen> createState() => _BatchQrViewScreenState();
}

class _BatchQrViewScreenState extends State<BatchQrViewScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<TraceabilityBloc>()
        .add(FetchTraceabilityEvent(widget.batchQrCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Provenance & Traceability'),
      ),
      body: BlocBuilder<TraceabilityBloc, TraceabilityState>(
        builder: (context, state) {
          if (state is TraceabilityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TraceabilityErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is TraceabilityLoadedState) {
            final prov = state.provenance;
            final farmer = prov.farmerProfile;
            final loc = prov.farmLocation;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // QR Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                            ),
                            child: QrImageView(
                              data: prov.verificationUrl,
                              version: QrVersions.auto,
                              size: 180.0,
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.primary,
                              ),
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            prov.batchQrCode,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Scan with any smartphone to verify origin and chemical safety',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Origin & Farmer Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(prov.cropTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Grade ${prov.grade}',
                                    style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _infoRow('Farmer Name',
                              farmer['name'] ?? 'Verified Grower'),
                          _infoRow('Agro-Bridge Trust Score',
                              '${farmer['agroBridgeTrustScore'] ?? 765} (${farmer['trustTier'] ?? 'Gold'})'),
                          _infoRow('Farm GPS Location',
                              '${loc['upazila'] ?? 'Shibganj'}, ${loc['district'] ?? 'Bogura'} (${loc['division'] ?? 'Rajshahi'})'),
                          _infoRow('Harvest Date', prov.harvestDate),
                          _infoRow(
                              'Organic Cultivation',
                              prov.organicCertified
                                  ? 'Yes (Zero Chemical Pesticide)'
                                  : 'GAP Standard'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (prov.sprayRecords.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Spray Records',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 10),
                            ...prov.sprayRecords.map((record) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.science_outlined,
                                      color: AppColors.primary),
                                  title: Text(record.chemical),
                                  subtitle: Text(
                                      '${record.date} • ${record.preHarvestDays} day pre-harvest interval'),
                                )),
                            if (prov.harvestWarning['warning'] == true)
                              Container(
                                padding: const EdgeInsets.all(10),
                                color: const Color(0xFFFFF1F2),
                                child: Text(
                                    prov.harvestWarning['message'] ??
                                        'Harvest falls inside a pre-harvest interval.',
                                    style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Quality & Laboratory Checks
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.biotech,
                                  color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text('Lab Inspection & Food Safety Parameters',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...prov.qualityChecks.map((q) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(q.parameter,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                        Text('Standard: ${q.standard}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade600)),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${q.result} • ${q.status}',
                                        style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
