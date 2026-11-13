import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/marketplace_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';

class AddCropScreen extends StatefulWidget {
  final UserEntity currentUser;
  const AddCropScreen({super.key, required this.currentUser});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Winter Cabbage Bulk (শীতকালীন বাঁধাকপি)');
  final _quantityController = TextEditingController(text: '150');
  final _priceController = TextEditingController(text: '800');
  final _minOrderController = TextEditingController(text: '20');
  final _descController = TextEditingController(text: 'Direct harvest from Bogura farm. Fresh, tight heads, free of pesticide residue.');

  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'Maund (মন)';
  String _selectedDivision = 'Rajshahi';
  String _selectedGrade = 'A';
  bool _organic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List New Harvest Lot')),
      body: BlocConsumer<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is CropCreatedSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Crop lot listed successfully!'), backgroundColor: AppColors.success),
            );
            Navigator.pop(context);
          } else if (state is MarketplaceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is MarketplaceLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Crop Lot Title (ফসলের শিরোনাম)'),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category (ক্যাটাগরি)'),
                          items: AppConstants.categories
                              .where((c) => c != 'All')
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(labelText: 'Unit (একক)'),
                          items: AppConstants.units
                              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedUnit = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Total Quantity (মোট পরিমাণ)'),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price/Unit BDT (দর/টাকা)'),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minOrderController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min Order Qty (সর্বনিম্ন অর্ডার)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGrade,
                          decoration: const InputDecoration(labelText: 'Quality Grade (গ্রেড)'),
                          items: const [
                            DropdownMenuItem(value: 'A+', child: Text('Grade A+ (Premium)')),
                            DropdownMenuItem(value: 'A', child: Text('Grade A (Standard)')),
                            DropdownMenuItem(value: 'B', child: Text('Grade B (Commercial)')),
                          ],
                          onChanged: (val) => setState(() => _selectedGrade = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDivision,
                    decoration: const InputDecoration(labelText: 'Farm Division (বিভাগ)'),
                    items: AppConstants.divisions
                        .where((d) => d != 'All')
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedDivision = val!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Lot Details & Harvesting Notes'),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Organic / Good Agricultural Practice (GAP)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Certified chemical-free farming', style: TextStyle(fontSize: 12)),
                    value: _organic,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _organic = val),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<MarketplaceBloc>().add(
                                    CreateCropEvent({
                                      'title': _titleController.text.trim(),
                                      'category': _selectedCategory,
                                      'quantity': double.parse(_quantityController.text.trim()),
                                      'unit': _selectedUnit,
                                      'pricePerUnit': double.parse(_priceController.text.trim()),
                                      'minOrderQuantity': double.parse(_minOrderController.text.trim()),
                                      'description': _descController.text.trim(),
                                      'division': _selectedDivision,
                                      'district': widget.currentUser.district,
                                      'upazila': widget.currentUser.upazila,
                                      'grade': _selectedGrade,
                                      'organicCertified': _organic,
                                      'harvestDate': DateTime.now().toString().split(' ').first,
                                    }),
                                  );
                            }
                          },
                    child: Text(isLoading ? 'Publishing...' : 'Publish Lot on Marketplace'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

