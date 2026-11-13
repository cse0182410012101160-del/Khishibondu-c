import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/marketplace_bloc.dart';

class BiddingSheet extends StatefulWidget {
  final String cropId;
  final String unit;
  final double totalQuantity;
  final double askingPricePerUnit;

  const BiddingSheet({
    super.key,
    required this.cropId,
    required this.unit,
    required this.totalQuantity,
    required this.askingPricePerUnit,
  });

  @override
  State<BiddingSheet> createState() => _BiddingSheetState();
}

class _BiddingSheetState extends State<BiddingSheet> {
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  final _noteController = TextEditingController(text: 'Will pick up harvest via dedicated freight truck within 48 hours.');

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.totalQuantity.toStringAsFixed(0));
    _priceController = TextEditingController(text: (widget.askingPricePerUnit * 0.95).toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final total = qty * price;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Submit Bulk Lot Bid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Asking Price: ${widget.askingPricePerUnit} BDT / ${widget.unit.split(" ").first}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Lot Quantity Wanted (${widget.unit})',
              suffixText: widget.unit.split(' ').first,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Offered Price per Unit (BDT)',
              prefixText: '৳ ',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Logistics / Pickup Note for Farmer'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Offer Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${total.toStringAsFixed(0)} BDT',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () {
              context.read<MarketplaceBloc>().add(
                    SubmitBidEvent(
                      widget.cropId,
                      {
                        'quantityRequested': qty,
                        'offeredPricePerUnit': price,
                        'note': _noteController.text.trim(),
                      },
                    ),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bid submitted to farmer!'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Confirm & Send Bid to Farmer'),
          ),
        ],
      ),
    );
  }
}

