// ============================================================================
// BloodNorms | design_component_gallery_view.dart
// Interactive Design System Component Gallery for Developers and Designers
// Showcases tokens, pill buttons, stat cards, segmented pickers, and states
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/app_stat_card.dart';
import '../../../shared/widgets/segmented_picker.dart';

class DesignComponentGalleryView extends StatefulWidget {
  const DesignComponentGalleryView({super.key});

  @override
  State<DesignComponentGalleryView> createState() => _DesignComponentGalleryViewState();
}

class _DesignComponentGalleryViewState extends State<DesignComponentGalleryView> {
  String _selectedSegment = 'donors';

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
          const Text(
            'Design system component gallery',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Interactive showcase of all design tokens, pill controls, stat cards, and status surfaces',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Pill Buttons (min 44px tap target)'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppPillButton(
                label: 'Primary action',
                icon: Icons.check_rounded,
                variant: AppPillButtonVariant.primary,
                onPressed: () {},
              ),
              AppPillButton(
                label: 'Secondary outline',
                icon: Icons.refresh_rounded,
                variant: AppPillButtonVariant.secondary,
                onPressed: () {},
              ),
              AppPillButton(
                label: 'Tonal accent',
                icon: Icons.bolt_rounded,
                variant: AppPillButtonVariant.tonal,
                onPressed: () {},
              ),
              AppPillButton(
                label: 'Destructive',
                icon: Icons.delete_outline_rounded,
                variant: AppPillButtonVariant.destructive,
                onPressed: () {},
              ),
              AppPillButton(
                label: 'Loading state',
                variant: AppPillButtonVariant.primary,
                isLoading: true,
                onPressed: () {},
              ),
              AppPillButton(
                label: 'Disabled',
                variant: AppPillButtonVariant.primary,
                onPressed: null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Sliding Segmented Control'),
          const SizedBox(height: 12),
          SegmentedPicker<String>(
            selectedValue: _selectedSegment,
            onValueChanged: (val) => setState(() => _selectedSegment = val),
            items: const [
              SegmentItem(value: 'donors', label: 'Donors', icon: Icons.people_outline_rounded),
              SegmentItem(value: 'camps', label: 'Camps', icon: Icons.event_available_outlined),
              SegmentItem(value: 'centers', label: 'Blood Centers', icon: Icons.local_hospital_outlined),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Search Field Pill'),
          const SizedBox(height: 12),
          const AppSearchField(hintText: 'Search anything across platform...'),
          const SizedBox(height: 24),
          _buildSectionTitle('Stat Metric Cards'),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: AppStatCard(
                  label: 'Registered donors',
                  value: '1,420',
                  subtitle: '+12% this month',
                  icon: Icons.people_outline_rounded,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: AppStatCard(
                  label: 'Emergency match rate',
                  value: '98.4%',
                  subtitle: '< 4 min average',
                  icon: Icons.speed_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Empty State'),
          const SizedBox(height: 12),
          const AppEmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No pending requests',
            description: 'All blood donation requests have been fulfilled and verified.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: BrandTypography.fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: BrandColors.textPrimary,
      ),
    );
  }
}

