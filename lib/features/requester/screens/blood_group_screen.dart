// ============================================================================
// BloodNorms | blood_group_screen.dart
// Clean, minimal blood group selector screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/blood_group_tile.dart';
import '../../../shared/widgets/screen_header.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/blood_group_help_sheet.dart';

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
      backgroundColor: BrandColors.background,
      appBar: ScreenHeader(
        title: loc.t('group.title'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.t('group.title'),
                      style: BrandTypography.title1(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose the exact blood group required for the patient',
                      style: BrandTypography.body(color: BrandColors.textSecondary),
                    ),
                    const SizedBox(height: 28),

                    // Grid of Blood Group Tiles
                    Center(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: BloodGroup.values.map((bg) {
                          return BloodGroupTile(
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

                    // Help Card if Blood Group is Unknown
                    GestureDetector(
                      onTap: () => showBloodGroupHelpSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: BrandColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                          border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.help_outline_rounded,
                              size: 20,
                              color: BrandColors.accent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.t('group.unknown'),
                                style: BrandTypography.label(color: BrandColors.textPrimary),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: BrandColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky Clean Continue Pill CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: AppPillButton(
                  label: loc.t('cta.continue'),
                  variant: _selected != null
                      ? AppPillButtonVariant.primary
                      : AppPillButtonVariant.secondary,
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
}
