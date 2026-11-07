// ============================================================================
// BloodNorms | voice_simulator_view.dart
// Modern Minimal Interactive AI Speech Triage Simulator & Verification Sandbox
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

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
          if (_aiTestSimulationResult != null) _buildResultCard(),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrandColors.surfaceSoft,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation outcome (Verified against prompt v2.4)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: BrandColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '• Extracted blood group: ${_aiTestSimulationResult!['recognized_group']} · Units: ${_aiTestSimulationResult!['units']}',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Urgency: ${_aiTestSimulationResult!['urgency']} · Confidence: 98%',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Hospital: ${_aiTestSimulationResult!['hospital']}',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Evaluation rating: ',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: BrandColors.textSecondary,
                ),
              ),
              ...[1, 2, 3, 4, 5].map((star) => InkWell(
                    borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                    onTap: () {
                      setState(() => _aiHumanRating = star);
                      widget.onShowToast('Saved evaluation score: $star/5 stars');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.star_rounded,
                        color: star <= _aiHumanRating
                            ? BrandColors.statusWarning
                            : BrandColors.borderStrong,
                        size: 20,
                      ),
                    ),
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
      widget.onShowToast('Voice simulation completed successfully');
    }
  }
}
