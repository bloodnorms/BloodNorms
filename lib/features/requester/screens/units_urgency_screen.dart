// ============================================================================
// BloodNorms | units_urgency_screen.dart
// Units & Urgency selection screen — Thin Screen Composing Stepper & Pickers
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/segmented_picker.dart';
import '../../../shared/widgets/speech_bubble.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/blood_component_selector_card.dart';
import '../widgets/blood_component_sheet.dart';

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

  void _showComponentModal(BuildContext context) {
    showBloodComponentPickerSheet(
      context: context,
      selectedComponent: _component,
      onSelected: (val) {
        setState(() => _component = val);
        globalRequestFlow.setComponent(val);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: ScreenHeader(
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
                    const SpeechBubble(
                      emoji: '⏱️',
                      text: 'Specify how many units you need and when the blood is required.',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Units',
                      style: BrandTypography.title2(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: BrandColors.background,
                        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                      ),
                      child: Center(
                        child: QuantityStepper(
                          value: _units,
                          min: 1,
                          max: 10,
                          onChanged: (val) {
                            setState(() => _units = val);
                            globalRequestFlow.setUnits(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Urgency Level',
                      style: BrandTypography.title3(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    SegmentedPicker<RequestUrgencyLevel>(
                      items: const [
                        SegmentItem(
                          value: RequestUrgencyLevel.now,
                          label: 'NOW',
                          icon: Icons.bolt_rounded,
                        ),
                        SegmentItem(
                          value: RequestUrgencyLevel.within6h,
                          label: '6 HOURS',
                          icon: Icons.schedule_rounded,
                        ),
                        SegmentItem(
                          value: RequestUrgencyLevel.within24h,
                          label: '24 HOURS',
                          icon: Icons.calendar_month_rounded,
                        ),
                      ],
                      selectedValue: _urgency,
                      activeColor: BrandColors.primaryAction,
                      onValueChanged: (val) {
                        setState(() => _urgency = val);
                        globalRequestFlow.setUrgency(val);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Blood Component',
                      style: BrandTypography.title3(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    BloodComponentSelectorCard(
                      component: _component,
                      onTap: () => _showComponentModal(context),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: BrandColors.background,
                border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
              ),
              child: SafeArea(
                top: false,
                child: AppPillButton(
                  label: loc.t('cta.continue'),
                  variant: AppPillButtonVariant.primary,
                  isFullWidth: true,
                  onPressed: () => context.push('/location'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
