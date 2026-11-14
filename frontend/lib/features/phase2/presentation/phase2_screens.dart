import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:agro_bridge/core/di/injection.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/core/theme/app_theme.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/core/widgets/agro_image.dart';
import 'package:agro_bridge/features/auth/domain/entities/user_entity.dart';
import '../data/phase2_api.dart';

Phase2Api _api() => Phase2Api(sl<ApiClient>());

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _questionController = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String? _answer;
  bool _loading = false;
  bool _listening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('bn-BD');
  }

  Future<void> _toggleSpeech() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    try {
      final available = await _speech.initialize();
      if (!available) throw StateError('Speech recognition unavailable');
      if (mounted) {
        setState(() {
          _listening = true;
          _error = null;
        });
      }
      await _speech.listen(
        listenOptions: SpeechListenOptions(localeId: 'bn_BD'),
        onResult: (result) {
          if (mounted) {
            setState(() => _questionController.text = result.recognizedWords);
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _listening = false;
          _error = AppLocalizations.of(context).translate('speechFallback');
        });
      }
    }
  }

  Future<void> _ask() async {
    if (_questionController.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api().assist(_questionController.text.trim());
      final answer = result['response'] as String?;
      setState(() => _answer = answer);
      if (answer != null) {
        try {
          await _tts.speak(answer);
        } catch (_) {
          // Text response remains available when speech output is unavailable.
        }
      }
    } catch (error) {
      setState(() => _error = 'Assistant unavailable. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('assistantTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(loc.translate('assistantPrompt'),
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _questionController,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: loc.translate('yourQuestion'),
              hintText: loc.translate('assistantHint'),
              suffixIcon: IconButton(
                tooltip: loc.translate('speechInput'),
                icon: Icon(
                    _listening ? Icons.stop_circle_outlined : Icons.mic_none),
                onPressed: _toggleSpeech,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _ask,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(_loading
                ? loc.translate('thinking')
                : loc.translate('askAssistant')),
          ),
          if (_error != null) _errorBox(_error!),
          if (_answer != null)
            _resultCard(loc.translate('assistantResponse'), _answer!),
          const SizedBox(height: 12),
          Text(loc.translate('assistantAdvisory'),
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}

class CropQualityScreen extends StatefulWidget {
  const CropQualityScreen({super.key});

  @override
  State<CropQualityScreen> createState() => _CropQualityScreenState();
}

class _CropQualityScreenState extends State<CropQualityScreen> {
  final _photoController = TextEditingController();
  final _cropController = TextEditingController(text: 'onion');
  Map<String, dynamic>? _result;
  String? _error;
  bool _loading = false;

  Future<void> _check() async {
    if (_photoController.text.trim().length < 20) {
      setState(() =>
          _error = 'Paste an encoded photo value with at least 20 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api().verifyCropPhoto(
          _photoController.text.trim(),
          cropType: _cropController.text.trim());
      setState(
          () => _result = Map<String, dynamic>.from(response['result'] as Map));
    } catch (error) {
      setState(() => _error = 'Photo verification unavailable.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _photoController.dispose();
    _cropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Quality Check')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _cropController,
              decoration: const InputDecoration(labelText: 'Crop type')),
          const SizedBox(height: 12),
          TextField(
              controller: _photoController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                  labelText: 'Photo data',
                  hintText: 'Paste base64 or upload payload')),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: _loading ? null : _check,
              icon: const Icon(Icons.verified_outlined),
              label: Text(_loading ? 'Checking...' : 'Check quality')),
          if (_error != null) _errorBox(_error!),
          if (_result != null)
            _resultCard('Grade ${_result!['grade']}',
                'Confidence: ${((_result!['confidence'] as num) * 100).round()}%\n${(_result!['reasons'] as List).join('\n')}'),
          const SizedBox(height: 12),
          const Text(
              'This is an advisory sandbox result, not a certified quality inspection.',
              style: TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}

class ProcurementScreen extends StatefulWidget {
  const ProcurementScreen({super.key});

  @override
  State<ProcurementScreen> createState() => _ProcurementScreenState();
}

class _ProcurementScreenState extends State<ProcurementScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _lots = [];
  List<dynamic> _suppliers = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result =
          await _api().getProcurement(search: _searchController.text.trim());
      setState(() {
        _lots = List<dynamic>.from(result['lots'] as List? ?? []);
        _suppliers = List<dynamic>.from(result['suppliers'] as List? ?? []);
        _error = null;
      });
    } catch (error) {
      setState(() => _error = 'Procurement data unavailable.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Procurement')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AgroImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=1200&auto=format&fit=crop',
              height: 150,
              width: double.infinity,
              borderRadius: BorderRadius.circular(14),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Paikari Bajar • Wholesale sourcing',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
                controller: _searchController,
                onSubmitted: (_) => _load(),
                decoration: const InputDecoration(
                    labelText: 'Search lots', suffixIcon: Icon(Icons.search))),
            const SizedBox(height: 16),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null) _errorBox(_error!),
            if (!_loading) ...[
              Text('${_lots.length} available lots',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._lots.map((lot) => Card(
                  child: ListTile(
                      title: Text('${lot['title']}'),
                      subtitle: Text(
                          '${lot['quantity']} ${lot['unit']} • ${lot['district']}'),
                      trailing: Text('BDT ${lot['pricePerUnit']}')))),
              const SizedBox(height: 16),
              const Text('Suppliers',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._suppliers.map((supplier) => ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('${supplier['farmerName']}'),
                  subtitle: Text(
                      '${supplier['district']} • ${supplier['activeLots']} active lots'),
                  trailing: Text('${supplier['rating']}'))),
            ],
          ],
        ),
      ),
    );
  }
}

class NgoAnalyticsScreen extends StatefulWidget {
  const NgoAnalyticsScreen({super.key});

  @override
  State<NgoAnalyticsScreen> createState() => _NgoAnalyticsScreenState();
}

class _NgoAnalyticsScreenState extends State<NgoAnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _api().getNgoAnalytics();
      setState(() =>
          _analytics = Map<String, dynamic>.from(result['analytics'] as Map));
    } catch (error) {
      setState(() => _error = 'NGO analytics unavailable.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _analytics;
    return Scaffold(
      appBar: AppBar(title: const Text('NGO Portfolio Analytics')),
      body: _error != null
          ? _errorBox(_error!)
          : analytics == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _metric('Applicants', '${analytics['applicants']}',
                          Icons.people_outline),
                      _metric(
                          'EMI collection rate',
                          '${analytics['emiCollectionRatePct']}%',
                          Icons.payments_outlined),
                      _metric('Default risk', '${analytics['defaultRatePct']}%',
                          Icons.warning_amber_outlined),
                      const SizedBox(height: 12),
                      const Text('Credit score distribution',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _resultCard(
                          'Portfolio', '${analytics['scoreDistribution']}'),
                      const Text('District risk',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...(analytics['districtRisk'] as List).map((district) =>
                          ListTile(
                              title: Text('${district['district']}'),
                              subtitle:
                                  Text('${district['applicants']} applicants'),
                              trailing:
                                  Text('BDT ${district['requestedBdt']}'))),
                    ],
                  ),
                ),
    );
  }
}

class SandboxPaymentScreen extends StatefulWidget {
  final UserEntity currentUser;
  const SandboxPaymentScreen({super.key, required this.currentUser});

  @override
  State<SandboxPaymentScreen> createState() => _SandboxPaymentScreenState();
}

class InputShopScreen extends StatefulWidget {
  const InputShopScreen({super.key});

  @override
  State<InputShopScreen> createState() => _InputShopScreenState();
}

class _InputShopScreenState extends State<InputShopScreen> {
  List<dynamic> _products = [];
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _api().getInputShop();
      if (mounted) {
        setState(() =>
            _products = List<dynamic>.from(result['products'] as List? ?? []));
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'Input shop unavailable.');
    }
  }

  Future<void> _apply(dynamic product) async {
    try {
      final result = await _api().applyBnpl(
          productId: product['id'] as String, quantity: 1, tenureMonths: 3);
      if (mounted) {
        setState(() => _message =
            'BNPL application submitted. Monthly installment: BDT ${result['application']['monthlyInstallmentBdt']}');
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'BNPL application failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BNPL Input Shop')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Buy approved farm inputs now and repay after harvest.',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ..._products.map((product) => Card(
                child: ListTile(
                    title: Text('${product['name']}'),
                    subtitle: Text('${product['unit']} • ${product['vendor']}'),
                    trailing: FilledButton(
                        onPressed: () => _apply(product),
                        child: Text('BDT ${product['priceBdt']}'))))),
            if (_message != null) _resultCard('BNPL status', _message!),
          ],
        ),
      ),
    );
  }
}

class SoilSensorsScreen extends StatefulWidget {
  const SoilSensorsScreen({super.key});

  @override
  State<SoilSensorsScreen> createState() => _SoilSensorsScreenState();
}

class _SoilSensorsScreenState extends State<SoilSensorsScreen> {
  List<dynamic> _readings = [];
  String? _recommendation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _api().getSensors();
      if (mounted) {
        setState(() {
          _readings = List<dynamic>.from(result['readings'] as List? ?? []);
          _recommendation = result['recommendation'] as String?;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _recommendation = 'Sensor data unavailable.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Soil Sensors')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_recommendation != null)
              _resultCard('Field recommendation', _recommendation!),
            ..._readings.map(_readingCard),
          ],
        ),
      ),
    );
  }

  Widget _readingCard(dynamic reading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${reading['sensorId']} • ${reading['district']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                'Moisture ${reading['moisturePct']}%  |  N ${reading['nitrogenPpm']} ppm  |  P ${reading['phosphorusPpm']} ppm  |  K ${reading['potassiumPpm']} ppm'),
            const SizedBox(height: 6),
            Text('Battery ${reading['batteryPct']}%',
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class ExportMatchmakingScreen extends StatefulWidget {
  const ExportMatchmakingScreen({super.key});

  @override
  State<ExportMatchmakingScreen> createState() =>
      _ExportMatchmakingScreenState();
}

class _ExportMatchmakingScreenState extends State<ExportMatchmakingScreen> {
  List<dynamic> _matches = [];
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _api().getExportMatches();
      if (mounted) {
        setState(() =>
            _matches = List<dynamic>.from(result['matches'] as List? ?? []));
      }
    } catch (error) {
      if (mounted) setState(() => _message = 'Export matches unavailable.');
    }
  }

  Future<void> _inquire(String matchId) async {
    try {
      final result = await _api().createExportInquiry(matchId);
      if (mounted) {
        setState(() => _message =
            'Export inquiry ${result['inquiry']['id']} submitted for review.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Could not submit export inquiry.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Matchmaking')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
                'Find international demand that matches your harvest and certifications.',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            ..._matches.map(_matchCard),
            if (_message != null) _resultCard('Matchmaking status', _message!),
          ],
        ),
      ),
    );
  }

  Widget _matchCard(dynamic match) {
    return Card(
      child: ListTile(
        title: Text('${match['cropType']} to ${match['destination']}'),
        subtitle: Text(
            '${match['requiredQuantityKg']} kg • BDT ${match['targetPriceBdtPerKg']}/kg\n${(match['certifications'] as List).join(', ')}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.outbox_outlined),
          tooltip: 'Send inquiry',
          onPressed: () => _inquire(match['id'] as String),
        ),
      ),
    );
  }
}

class _SandboxPaymentScreenState extends State<SandboxPaymentScreen> {
  String _rail = 'bKash';
  bool _loading = false;
  String? _message;

  Future<void> _fund() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result = await _api().fundSandboxPayment(
        orderId: 'ord_502',
        paymentRail: _rail,
        payerMfsNumber: widget.currentUser.mfsNumber,
        idempotencyKey: const Uuid().v4(),
      );
      setState(() => _message =
          '${result['message']}\nReference: ${result['transactionId']}');
    } catch (error) {
      setState(() => _message = 'Payment could not be started.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sandbox Escrow Funding')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Demo order: ord_502',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                initialValue: _rail,
                items: const [
                  DropdownMenuItem(value: 'bKash', child: Text('bKash')),
                  DropdownMenuItem(value: 'Nagad', child: Text('Nagad'))
                ],
                onChanged: (value) => setState(() => _rail = value ?? 'bKash'),
                decoration: const InputDecoration(labelText: 'Payment rail')),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: _loading ? null : _fund,
                icon: const Icon(Icons.lock_outline),
                label: Text(
                    _loading ? 'Starting...' : 'Lock funds in sandbox escrow')),
            if (_message != null) _resultCard('Payment result', _message!),
            const SizedBox(height: 12),
            const Text('Sandbox only. No real money is moved.',
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

Widget _errorBox(String message) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(message, style: const TextStyle(color: AppColors.error)));

Widget _resultCard(String title, String value) => Card(
    margin: const EdgeInsets.only(top: 16),
    child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value)
        ])));

Widget _metric(String title, String value, IconData icon) => Card(
    child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: Text(value,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))));
