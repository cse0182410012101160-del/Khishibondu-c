import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/marketplace_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:agro_bridge/features/traceability/presentation/screens/batch_qr_view_screen.dart';
import 'bidding_dialog.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropId;
  final UserEntity currentUser;

  const CropDetailScreen({super.key, required this.cropId, required this.currentUser});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  Map<String, dynamic>? _cropData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    // Read from state or repository
    final state = context.read<MarketplaceBloc>().state;
    if (state is CropsLoadedState) {
      final crop = state.crops.firstWhere((c) => c.id == widget.cropId, orElse: () => state.crops.first);
      setState(() {
        _cropData = {
          'id': crop.id,
          'title': crop.title,
          'titleBn': crop.titleBn,
          'farmerId': crop.farmerId,
          'farmerName': crop.farmerName,
          'farmerRating': crop.farmerRating,
          'category': crop.category,
          'quantity': crop.quantity,
          'unit': crop.unit,
          'pricePerUnit': crop.pricePerUnit,
          'minOrder': crop.minOrderQuantity,
          'description': crop.description,
          'descriptionBn': crop.descriptionBn,
          'division': crop.division,
          'district': crop.district,
          'upazila': crop.upazila,
          'harvestDate': crop.harvestDate,
          'grade': crop.grade,
          'organic': crop.organicCertified,
          'batchQrCode': crop.batchQrCode,
          'status': crop.status,
          'images': crop.images,
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _cropData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isOwner = widget.currentUser.id == _cropData!['farmerId'];
    final isBuyer = widget.currentUser.role == 'buyer' || widget.currentUser.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(_cropData!['title']),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'View Batch Provenance QR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BatchQrViewScreen(batchQrCode: _cropData!['batchQrCode']),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: isBuyer && !isOwner
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Lot Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${_cropData!['pricePerUnit']} BDT / ${_cropData!['unit'].split(" ").first}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => BiddingSheet(
                          cropId: _cropData!['id'],
                          unit: _cropData!['unit'],
                          totalQuantity: _cropData!['quantity'],
                          askingPricePerUnit: _cropData!['pricePerUnit'],
                        ),
                      );
                    },
                    icon: const Icon(Icons.gavel),
                    label: const Text('Place Bulk Bid'),
                  ),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Image.network(
              (_cropData!['images'] as List).isNotEmpty
                  ? _cropData!['images'][0]
                  : 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&fit=crop',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _cropData!['category'],
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Status: ${_cropData!['status']}',
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _cropData!['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _cropData!['titleBn'],
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 14),

                  // Location and Farmer Card
                  Card(
                    color: AppColors.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_cropData!['farmerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('${_cropData!['upazila']}, ${_cropData!['district']} (${_cropData!['division']})',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.secondary, size: 14),
                                const SizedBox(width: 4),
                                Text('${_cropData!['farmerRating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Batch Provenance Banner
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BatchQrViewScreen(batchQrCode: _cropData!['batchQrCode']),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: AppColors.success, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Verifiable Batch: ${_cropData!['batchQrCode']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success)),
                                const Text('Tap to view origin GPS, harvest date, and quality audit',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.success),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lot Specifications Grid
                  const Text('Harvest Lot Specifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _specItem('Total Available', '${_cropData!['quantity']} ${_cropData!['unit']}'),
                      _specItem('Min Order', '${_cropData!['minOrder']} ${_cropData!['unit']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _specItem('Harvest Date', _cropData!['harvestDate']),
                      _specItem('Quality Grade', 'Grade ${_cropData!['grade']}'),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('Lot Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(_cropData!['description'], style: const TextStyle(fontSize: 14, height: 1.4)),
                  const SizedBox(height: 8),
                  Text(_cropData!['descriptionBn'], style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specItem(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

