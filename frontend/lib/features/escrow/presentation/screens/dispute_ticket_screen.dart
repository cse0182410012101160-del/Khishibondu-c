import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/escrow_bloc.dart';

class DisputeTicketScreen extends StatefulWidget {
  final String orderId;
  const DisputeTicketScreen({super.key, required this.orderId});

  @override
  State<DisputeTicketScreen> createState() => _DisputeTicketScreenState();
}

class _DisputeTicketScreenState extends State<DisputeTicketScreen> {
  final _reasonController = TextEditingController();
  String _selectedIssueType = 'Moisture / Quality Below Specifications';

  final List<String> _issueTypes = [
    'Moisture / Quality Below Specifications',
    'Weight Mismatch / Short Delivery',
    'Pest / Disease Damage in Transit',
    'Delivery Delay Beyond Agreed Window',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Escrow Dispute')),
      body: BlocConsumer<EscrowBloc, EscrowState>(
        listener: (context, state) {
          if (state is DisputeRaisedSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dispute ticket raised! Escrow payout is now frozen pending moderator arbitration.'),
                backgroundColor: AppColors.warning,
              ),
            );
            Navigator.pop(context);
          } else if (state is EscrowErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EscrowLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppColors.error, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Filing a dispute pauses the automatic escrow release for Order #${widget.orderId.split("_").last.toUpperCase()}. A certified agricultural moderator will arbitrate.',
                          style: const TextStyle(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _selectedIssueType,
                  decoration: const InputDecoration(labelText: 'Primary Dispute Reason'),
                  items: _issueTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) => setState(() => _selectedIssueType = val!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detailed Explanation & Defect Report',
                    hintText: 'Describe measured moisture percentage, physical damage, or delivery discrepancy...',
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_camera, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Attach digital moisture meter reading or harvest photo evidence', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Add Photo')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_reasonController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please describe the dispute reason.')),
                            );
                            return;
                          }
                          context.read<EscrowBloc>().add(
                                RaiseDisputeEvent({
                                  'orderId': widget.orderId,
                                  'reason': '[$_selectedIssueType] ${_reasonController.text.trim()}',
                                  'evidencePhotos': [
                                    'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&fit=crop'
                                  ]
                                }),
                              );
                        },
                  child: Text(isLoading ? 'Submitting...' : 'Freeze Escrow & Submit Dispute Ticket'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

