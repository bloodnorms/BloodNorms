// ============================================================================
// BloodNorms | blood_group_screen.dart
// Blood Group selector screen — Duolingo Feather Red Style
// 4x2 Tactile 3D Tiles, Mascot speech bubble, Material Icons, Arial
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/blood_groups.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_blood_tile.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../providers/request_flow_provider.dart';

class BloodGroupScreen extends StatefulWidget {
  const BloodGroupScreen({super.key});

  @override
  State<BloodGroupScreen> createState() => _BloodGroupScreenState();
}

class _BloodGroupScreenState extends State<BloodGroupScreen> {
  BloodGroup? _selected;

  @override
  void initState() {
    super.initState();
    _selected = globalRequestFlow.state.bloodGroup;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: loc.t('group.title'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duolingo Speech Bubble
                    const DuoSpeechBubble(
                      emoji: '🩸',
                      text: 'Which blood group does the patient need? Select the exact group below!',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.t('group.title'),
                      style: DuoTypography.title1(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose the exact blood group required',
                      style: DuoTypography.subhead(color: DuoColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // 4x2 Grid of 3D Blood Tiles
                    Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: BloodGroup.values.map((bg) {
                          return DuoBloodTile(
                            bloodGroup: bg,
                            isSelected: _selected == bg,
                            size: 80,
                            onTap: () {
                              setState(() => _selected = bg);
                              globalRequestFlow.setBloodGroup(bg);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // "Don't know" 3D card
                    GestureDetector(
                      onTap: () => _showDontKnowModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: DuoColors.border, width: 2.0),
                          boxShadow: const [
                            BoxShadow(
                              color: DuoColors.border,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('🤔', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.t('group.unknown'),
                                style: DuoTypography.headline(color: DuoColors.textPrimary),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: DuoColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky 3D Continue CTA in Pure White Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DuoButton(
                  label: loc.t('cta.continue'),
                  variant: _selected != null ? DuoButtonVariant.primary : DuoButtonVariant.secondary,
                  onPressed: _selected != null
                      ? () => context.push('/units')
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDontKnowModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DuoColors.redTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: DuoColors.red, width: 1.5),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: DuoColors.red, size: 24),
                ),
                const SizedBox(width: 12),
                Text("Don't know the group?", style: DuoTypography.title2(color: DuoColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Please check the hospital requisition slip or ask the attending doctor. You can still search blood banks right now, but finding live verified donors requires an exact blood group.',
              style: DuoTypography.body(color: DuoColors.textSecondary),
            ),
            const SizedBox(height: 20),
            DuoButton(
              label: 'BROWSE BLOOD BANKS NOW',
              variant: DuoButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/b');
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'BACK',
              variant: DuoButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
