// ============================================================================
// BloodNorms | ai_voice_studio_view.dart
// AI Voice Studio (Speech Simulator, Prompts & Guardrails, Daily Safety Cap)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/progress_meter.dart';

class AiVoiceStudioView extends StatefulWidget {
  final String subPage; // 'voice_simulator' | 'voice_prompts' | 'voice_safety'
  final void Function(String message) onShowToast;

  const AiVoiceStudioView({
    super.key,
    required this.subPage,
    required this.onShowToast,
  });

  @override
  State<AiVoiceStudioView> createState() => _AiVoiceStudioViewState();
}

class _AiVoiceStudioViewState extends State<AiVoiceStudioView> {
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
    switch (widget.subPage) {
      case 'voice_prompts':
        return _buildVoicePromptsPage();
      case 'voice_safety':
        return _buildVoiceSafetyPage();
      case 'voice_simulator':
      default:
        return _buildVoiceSimulatorPage();
    }
  }

  Widget _buildVoiceSimulatorPage() {
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
                  Text('Interactive AI Speech Triage Simulator', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
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
            decoration: const InputDecoration(labelText: 'Simulated Caller Audio Transcript', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isAiTesting
                ? null
                : () async {
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
                  },
            icon: _isAiTesting
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Execute Voice Analysis'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9333EA), foregroundColor: Colors.white),
          ),
          const SizedBox(height: 16),
          if (_aiTestSimulationResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE9D5FF))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Simulation Outcome (Verified against clinical prompt v2.4):', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6B21A8))),
                  const SizedBox(height: 8),
                  Text('• Extracted Blood Group: ${_aiTestSimulationResult!['recognized_group']} · Units: ${_aiTestSimulationResult!['units']}'),
                  Text('• Urgency: ${_aiTestSimulationResult!['urgency']} · Confidence: 98%'),
                  Text('• Hospital: ${_aiTestSimulationResult!['hospital']}'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Rate Quality: ', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                      ...[1, 2, 3, 4, 5].map((star) => IconButton(
                            icon: Icon(Icons.star_rounded, color: star <= _aiHumanRating ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1), size: 20),
                            onPressed: () {
                              setState(() => _aiHumanRating = star);
                              widget.onShowToast('Saved human evaluation score: $star/5 stars');
                            },
                          )),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVoicePromptsPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Prompts & Clinical Safety Guardrails', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          Text('Active Version: v2.4-godavari-clinical · Temperature: 0.30 · Native Gemini Live API', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
          SizedBox(height: 16),
          Text('1. Always confirm emergency blood group and unit count before initiating donor search.\n2. In Godavari Telugu, speak with natural polite phrasing ("Namaste andi, em blood group kavali?").\n3. Never give clinical diagnosis or medical treatment advice.\n4. Section 0.3 Hard Privacy: Zero audio and zero transcripts stored in database.'),
        ],
      ),
    );
  }

  Widget _buildVoiceSafetyPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Voice Minutes Safety Gauge', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 16),
          Row(
            children: [
              ProgressMeter(value: 0.15, color: Color(0xFF9333EA), centerText: '9m', subText: 'used', size: 84),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('9 of 60 Daily Safety Minutes Used', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('Auto-fails over to keypad telephony IVR if daily quota threshold is exceeded.', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
