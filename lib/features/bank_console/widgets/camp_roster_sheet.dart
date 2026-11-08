// ============================================================================
// BloodNorms | camp_roster_sheet.dart
// Verified Camp Attendee Roster Sheet for Bank Console
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';

void showCampRosterSheet({
  required BuildContext context,
  required CampModel camp,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService().getCampAttendees(camp.id),
      builder: (ctx, snapshot) {
        final attendees = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Camp Attendee Roster',
                      style: BrandTypography.title2(color: BrandColors.textPrimary)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrandColors.redTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${attendees.length} Verified',
                        style: const TextStyle(
                            color: BrandColors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(camp.title,
                  style: BrandTypography.caption(color: BrandColors.textSecondary)),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: BrandColors.red)))
              else if (attendees.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BrandColors.bgGrouped,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BrandColors.border, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      'No attendees checked in yet.\nTap "CHECK-IN" to verify arriving donors.',
                      textAlign: TextAlign.center,
                      style: BrandTypography.body(color: BrandColors.textSecondary),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 240,
                  child: ListView.separated(
                    itemCount: attendees.length,
                    separatorBuilder: (_, index) =>
                        const Divider(height: 1, color: BrandColors.border),
                    itemBuilder: (ctx, i) {
                      final att = attendees[i];
                      final donor = att['donors'] as Map<String, dynamic>?;
                      final name = donor?['first_name'] ??
                          att['phone'] ??
                          'Donor #${i + 1}';
                      final group = donor?['blood_group'] ?? 'O+';
                      final units = att['units'] ?? 1;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: BrandColors.greenTint,
                          child:
                              Icon(Icons.check_rounded, color: BrandColors.green),
                        ),
                        title: Text(name,
                            style: BrandTypography.title3(
                                color: BrandColors.textPrimary)),
                        subtitle: Text('$group · $units unit donated',
                            style: BrandTypography.caption(
                                color: BrandColors.textSecondary)),
                        trailing: const Text('VERIFIED',
                            style: TextStyle(
                                color: BrandColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              ActionButton(
                label: 'DONE',
                variant: ActionButtonVariant.primary,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    ),
  );
}
