// ============================================================================
// BloodNorms | voice_simulator_view.dart
// Modern Minimal Interactive AI Speech Triage Simulator & Verification Sandbox
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'voice_simulator_result_card.dart';

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
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI speech triage simulator',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Simulate natural caller speech and verify clinical entity extraction',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _aiTestLanguage,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English (Indian)')),
                  DropdownMenuItem(value: 'te', child: Text('Telugu (Godavari)')),
                  DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _aiTestLanguage = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiTestInputController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Simulated caller transcript',
            ),
          ),
          const SizedBox(height: 16),
          AppPillButton(
            label: 'Run voice analysis',
            icon: Icons.play_arrow_rounded,
            variant: AppPillButtonVariant.primary,
            isLoading: _isAiTesting,
            onPressed: _isAiTesting ? null : _runVoiceSimulation,
          ),
          const SizedBox(height: 16),
          if (_aiTestSimulationResult != null)
            VoiceSimulatorResultCard(
              result: _aiTestSimulationResult!,
              humanRating: _aiHumanRating,
              onRatingChanged: (star) {
                setState(() => _aiHumanRating = star);
                widget.onShowToast('Saved evaluation score: $star/5 stars');
              },
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
      widget.onShowToast('Voice simulation completed successfully');
    }
  }
}
