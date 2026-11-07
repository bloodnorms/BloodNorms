// ============================================================================
// BloodNorms | units_urgency_screen.dart
// Units, Urgency & Component selector — Duolingo Feather Red Style
// 3D Pushable Steppers, 3D Segmented Control, Mascot speech bubble, Material
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/segmented_picker.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../providers/request_flow_provider.dart';

class UnitsUrgencyScreen extends StatefulWidget {
  const UnitsUrgencyScreen({super.key});

  @override
  State<UnitsUrgencyScreen> createState() => _UnitsUrgencyScreenState();
}

class _UnitsUrgencyScreenState extends State<UnitsUrgencyScreen> {
  int _units = 1;
  RequestUrgencyLevel _urgency = RequestUrgencyLevel.now;
  BloodComponentType _component = BloodComponentType.wholeBlood;

  @override
  void initState() {
    super.initState();
    _units = globalRequestFlow.state.units;
    _urgency = globalRequestFlow.state.urgency;
    _component = globalRequestFlow.state.component;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: loc.t('units.title'),
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
                      emoji: '⏱️',
                      text: 'Specify how many units you need and when the blood is required.',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.t('units.title'),
                      style: DuoTypography.title1(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 16),

                    // 3D Stepper in Duolingo Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: DuoColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: DuoColors.border,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('UNITS NEEDED', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                          const SizedBox(height: 16),
                          DuoStepper(
                            value: _units,
                            min: 1,
                            max: 10,
                            onChanged: (val) {
                              setState(() => _units = val);
                              globalRequestFlow.setUnits(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Urgency 3D Segmented Control
                    Text(
                      'Urgency Level',
                      style: DuoTypography.title3(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    DuoSegmentControl<RequestUrgencyLevel>(
                      items: const [
                        DuoSegmentItem(
                          value: RequestUrgencyLevel.now,
                          label: 'NOW',
                          icon: Icons.bolt_rounded,
                        ),
                        DuoSegmentItem(
                          value: RequestUrgencyLevel.within6h,
                          label: '6 HOURS',
                          icon: Icons.schedule_rounded,
                        ),
                        DuoSegmentItem(
                          value: RequestUrgencyLevel.within24h,
                          label: '24 HOURS',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ],
                      selectedValue: _urgency,
                      activeColor: DuoColors.red,
                      activeShadowColor: DuoColors.redShadow,
                      onValueChanged: (val) {
                        setState(() => _urgency = val);
                        globalRequestFlow.setUrgency(val);
                      },
                    ),
                    const SizedBox(height: 28),

                    // Blood Component 3D Card
                    Text(
                      'Blood Component',
                      style: DuoTypography.title3(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _showComponentModal(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('🩸', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Text(
                                  _component.label,
                                  style: DuoTypography.headline(color: DuoColors.textPrimary),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 24,
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
            // Sticky 3D Continue
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
                  variant: DuoButtonVariant.primary,
                  onPressed: () => context.push('/location'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComponentModal(BuildContext context) {
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
            Text('Select Blood Component', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 16),
            ...BloodComponentType.values.map((type) {
              final isSelected = type == _component;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DuoButton(
                  label: type.label,
                  variant: isSelected ? DuoButtonVariant.primary : DuoButtonVariant.secondary,
                  height: 48,
                  onPressed: () {
                    setState(() => _component = type);
                    globalRequestFlow.setComponent(type);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            DuoButton(
              label: 'CANCEL',
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
