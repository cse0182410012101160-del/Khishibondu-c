import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'batch_qr_view_screen.dart';

class TraceScannerScreen extends StatefulWidget {
  const TraceScannerScreen({super.key});

  @override
  State<TraceScannerScreen> createState() => _TraceScannerScreenState();
}

class _TraceScannerScreenState extends State<TraceScannerScreen> {
  final _codeController = TextEditingController(text: 'QR-BOG-2026-POT-101');

  final List<String> _sampleBatches = [
    'QR-BOG-2026-POT-101', // Bogura Diamond Potato
    'QR-DIN-2026-KAT-102', // Dinajpur Kataribhog Rice
    'QR-BOG-2026-ONI-103', // Deshi Red Onion
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan & Trace Harvest Origin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, size: 64, color: AppColors.primary),
                  const SizedBox(height: 12),
                  const Text('Point camera at crop sack / crate QR tag', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Instant farmer provenance & quality verification', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Or enter Batch QR Code manually',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: () {
                    final code = _codeController.text.trim();
                    if (code.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BatchQrViewScreen(batchQrCode: code)),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                final code = _codeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BatchQrViewScreen(batchQrCode: code)),
                  );
                }
              },
              icon: const Icon(Icons.verified),
              label: const Text('Verify Batch Provenance'),
            ),
            const SizedBox(height: 28),
            const Text('Verified Bangladeshi Harvest Lots (Quick Demo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            ..._sampleBatches.map((code) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.qr_code_2, color: AppColors.primary),
                    title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      _codeController.text = code;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BatchQrViewScreen(batchQrCode: code)),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

