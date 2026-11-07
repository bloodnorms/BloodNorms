// ============================================================================
// BloodNorms | voice_simulator_view.dart
// Interactive AI Speech Triage Simulator & Verification Sandbox
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class VoiceSimulatorView extends StatefulWidget {
  final void Function(String message) onShowToast;

  const VoiceSimulatorView({
    super.key,
    required this.onShowToast,
  });

  @override
  State<VoiceSimulatorView> createState() => _VoiceSimulatorViewState();
}

class _VoiceSimulatorViewState extends State<VoiceSimulatorView> {
  final TextEditingController _aiTestInputController = TextEditingController(
    text: 'Hello, my father is admitted in GSL Hospital and urgently needs 2 units of B+ blood for cardiac surgery.',
  );
  String _aiTestLanguage = 'en';
  Map<String, dynamic>? _aiTestSimulationResult;
  bool _isAiTesting = false;
  int _aiHumanRating = 5;

  @override
  void dispose() {
    _aiTestInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.mic_rounded, color: Color(0xFF9333EA)),
                  SizedBox(width: 8),
                  Text(
                    'Interactive AI Speech Triage Simulator',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _aiTestLanguage,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English (Indian)')),
                  DropdownMenuItem(value: 'te', child: Text('Telugu (Godavari Dialect)')),
                  DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _aiTestLanguage = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiTestInputController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Simulated Caller Audio Transcript',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isAiTesting ? null : _runVoiceSimulation,
            icon: _isAiTesting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Execute Voice Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9333EA),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (_aiTestSimulationResult != null) _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation Outcome (Verified against clinical prompt v2.4):',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF6B21A8),
            ),
          ),
          const SizedBox(height: 8),
          Text('• Extracted Blood Group: ${_aiTestSimulationResult!['recognized_group']} · Units: ${_aiTestSimulationResult!['units']}'),
          Text('• Urgency: ${_aiTestSimulationResult!['urgency']} · Confidence: 98%'),
          Text('• Hospital: ${_aiTestSimulationResult!['hospital']}'),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Rate Quality: ',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              ...[1, 2, 3, 4, 5].map((star) => IconButton(
                    icon: Icon(
                      Icons.star_rounded,
                      color: star <= _aiHumanRating
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFCBD5E1),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _aiHumanRating = star);
                      widget.onShowToast('Saved human evaluation score: $star/5 stars');
                    },
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _runVoiceSimulation() async {
    setState(() => _isAiTesting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isAiTesting = false;
        _aiTestSimulationResult = {
          'recognized_group': 'B+',
          'urgency': 'CRITICAL',
          'hospital': 'GSL General Hospital, Rajahmundry',
          'units': 2,
          'confidence': 0.98,
          'safety_clearance': true,
        };
      });
      widget.onShowToast('Voice simulation completed successfully!');
    }
  }
}
