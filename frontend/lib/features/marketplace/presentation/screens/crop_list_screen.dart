import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/agro_image.dart';
import '../bloc/marketplace_bloc.dart';
import 'crop_detail_screen.dart';
import 'add_crop_screen.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:agro_bridge/features/microfinance/presentation/screens/credit_score_screen.dart';

class CropListScreen extends StatefulWidget {
  final UserEntity currentUser;
  /// Optional pre-selected division (used by GPS-based market discovery).
  final String? initialDivision;
  const CropListScreen({super.key, required this.currentUser, this.initialDivision});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  String _selectedCategory = 'All';
  String _selectedDivision = 'All';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialDivision != null && widget.initialDivision != 'All') {
      _selectedDivision = widget.initialDivision!;
    }
    _fetchCrops();
  }

  void _fetchCrops() {
    context.read<MarketplaceBloc>().add(
          FetchCropsEvent(
            category: _selectedCategory,
            division: _selectedDivision,
            search: _searchController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeCubit = context.read<LocaleCubit>();
    final isBn = loc.isBangla;
    final isFarmer = widget.currentUser.role == 'farmer';

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('marketplace')),
        actions: [
          // Language toggle button in app bar
          TextButton.icon(
            onPressed: () => localeCubit.toggleLocale(),
            icon: const Icon(Icons.language, color: Colors.white, size: 16),
            label: Text(
              isBn ? 'EN' : 'বাং',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCrops,
          ),
        ],
      ),
      floatingActionButton: isFarmer
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddCropScreen(currentUser: widget.currentUser)),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(loc.translate('listHarvest')),
            )
          : null,
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: loc.translate('searchCrops'),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _fetchCrops();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _fetchCrops(),
                ),
                const SizedBox(height: 10),
                // Categories
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = AppConstants.categories[index];
                      final isSelected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                            _fetchCrops();
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                // Divisions
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.divisions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final div = AppConstants.divisions[index];
                      final isSelected = _selectedDivision == div;
                      return FilterChip(
                        label: Text(div, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.grey.shade800)),
                        selected: isSelected,
                        selectedColor: AppColors.secondary,
                        checkmarkColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onSelected: (selected) {
                          setState(() => _selectedDivision = selected ? div : 'All');
                          _fetchCrops();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Get Credit Quick Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.steelMist.withValues(alpha: 0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'জামানতহীন কৃষিঋণ (Get Credit)' : 'Get Pre-Approved Credit',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        isBn ? 'বিক্রির রেকর্ডে ৳ ৫,০০,০০০ পর্যন্ত ঋণ' : 'Instant microloans based on sales volume',
                        style: const TextStyle(color: AppColors.steelMist, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreditScoreScreen(currentUser: widget.currentUser),
                      ),
                    );
                  },
                  child: Text(isBn ? 'ঋণ নিন' : 'Get Credit'),
                ),
              ],
            ),
          ),

          // Crops Stream List
          Expanded(
            child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
              builder: (context, state) {
                if (state is MarketplaceLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (state is MarketplaceErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('Unable to reach server. Checking offline cache...', style: TextStyle(color: Colors.grey.shade700)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _fetchCrops, child: const Text('Retry')),
                      ],
                    ),
                  );
                } else if (state is CropsLoadedState) {
                  final crops = state.crops;
                  if (crops.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('No harvest lots found in this division.', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: crops.length,
                    itemBuilder: (context, index) {
                      final crop = crops[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CropDetailScreen(
                                  cropId: crop.id,
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and Badges
                              Stack(
                                children: [
                                  AgroImage(
                                    imageUrl: crop.images.isNotEmpty
                                        ? crop.images.first
                                        : 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&fit=crop',
                                    height: 160,
                                    width: double.infinity,
                                  ),
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Grade ${crop.grade}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                  if (crop.organicCertified)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.eco, size: 12, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              'Organic',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            isBn ? (crop.titleBn.isNotEmpty ? crop.titleBn : crop.title) : crop.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            crop.status,
                                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: AppColors.textLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${crop.upazila}, ${crop.district} (${crop.division})',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.star, size: 14, color: AppColors.secondary),
                                        const SizedBox(width: 2),
                                        Text(
                                          crop.farmerRating.toStringAsFixed(1),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 18),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${loc.translate('lotSize')}: ${crop.quantity} ${crop.unit}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                            Text(
                                              '${loc.translate('minOrder')}: ${crop.minOrderQuantity} ${crop.unit}',
                                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${crop.pricePerUnit.toStringAsFixed(0)} ${loc.translate('taka')} / ${crop.unit.split(" ").first}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            if (crop.bidsCount > 0)
                                              Text(
                                                '${crop.bidsCount} ${loc.translate('activeBids')}',
                                                style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

