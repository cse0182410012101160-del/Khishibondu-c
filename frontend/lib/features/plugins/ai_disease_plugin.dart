import 'package:flutter/material.dart';
import '../../core/plugins/plugin_registry.dart';
import '../../core/theme/app_theme.dart';

class AiDiseaseDetectionPlugin extends FeaturePlugin {
  @override
  String get id => 'ai_disease_detection';

  @override
  String get title => 'AI Plant Disease Diagnosis';

  @override
  String get titleBn => 'কৃত্রিম বুদ্ধিমত্তা ফসল রোগ নির্ণয়';

  @override
  String get description =>
      'Take or upload a photo of affected crop leaves. Computer vision analyzes symptoms for late blight, blast, or nutrient deficiency.';

  @override
  String get version => '1.2.0';

  @override
  IconData get icon => Icons.document_scanner_outlined;

  @override
  List<String> get enabledRoles => ['farmer', 'admin'];

  @override
  Widget buildScreen(BuildContext context) {
    return const AiDiseaseScreen();
  }

  @override
  Widget? buildDashboardCard(BuildContext context) {
    return Card(
      color: const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBBF7D0)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.document_scanner_outlined, color: Colors.white, size: 20),
        ),
        title: const Text('AI Leaf Doctor Ready', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text('Instant crop disease detection from leaf photo', style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AiDiseaseScreen()));
        },
      ),
    );
  }
}

class AiDiseaseScreen extends StatefulWidget {
  const AiDiseaseScreen({super.key});

  @override
  State<AiDiseaseScreen> createState() => _AiDiseaseScreenState();
}

class _AiDiseaseScreenState extends State<AiDiseaseScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _diagnosisResult;

  void _runMockScan() {
    setState(() {
      _isAnalyzing = true;
      _diagnosisResult = null;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _diagnosisResult = {
            'crop': 'Potato (ডায়মন্ড আলু)',
            'disease': 'Potato Late Blight (আলুর নাবী ধসা রোগ)',
            'pathogen': 'Phytophthora infestans',
            'confidence': '96.4%',
            'severity': 'Moderate (মাঝারি)',
            'treatmentEn':
                'Spray Mancozeb (Dithane M-45) @ 2g/litre of water. Ensure spray reaches underside of leaves. Withhold irrigation for 3 days.',
            'treatmentBn':
                'ম্যানকোজেব (ডাইথেন এম-৪৫) প্রতি লিটার পানিতে ২ গ্রাম হারে স্প্রে করুন। পাতার নিচের অংশে ভালোভাবে স্প্রে পৌঁছে দিন এবং আগামী ৩ দিন সেচ বন্ধ রাখুন।'
          };
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Crop Disease Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo, size: 48, color: AppColors.primary),
                    const SizedBox(height: 12),
                    const Text('Snap or select crop leaf photo', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Bacterial blight, blast, brown spot, wilt', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _runMockScan,
              icon: _isAnalyzing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isAnalyzing ? 'Analyzing Leaf Patterns...' : 'Diagnose Disease Now'),
            ),
            const SizedBox(height: 24),
            if (_diagnosisResult != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.warning, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _diagnosisResult!['disease']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Confidence: ${_diagnosisResult!['confidence']}',
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Target Crop: ${_diagnosisResult!['crop']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('Pathogen: ${_diagnosisResult!['pathogen']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                      const Divider(height: 24),
                      const Text('Recommended Treatment (বাংলায় পরামর্শ):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(_diagnosisResult!['treatmentBn']!, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(_diagnosisResult!['treatmentEn']!, style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

