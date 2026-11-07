// ============================================================================
// BloodNorms | bank_camps_tab_view.dart
// Blood Bank Console: Camps Management Tab (Drives, Check-In, Broadcast)
// Modular Tab Composing Camp Cards, Schedule Dialog, and Check-In Sheets
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/camp_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import 'bank_broadcast_sheet.dart';
import 'bank_camp_card.dart';
import 'camp_checkin_sheet.dart';
import 'camp_roster_sheet.dart';
import 'schedule_camp_dialog.dart';

class BankCampsTabView extends StatelessWidget {
  final List<CampModel> bankCamps;
  final bool isLoadingCamps;
  final String selectedBankId;
  final VoidCallback onCampUpdated;
  final void Function(String message) onShowToast;

  const BankCampsTabView({
    super.key,
    required this.bankCamps,
    required this.isLoadingCamps,
    required this.selectedBankId,
    required this.onCampUpdated,
    required this.onShowToast,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.bgGrouped,
      appBar: ScreenHeader(
        title: 'Camp Management',
        showBackButton: false,
        trailing: [
          IconButton(
            onPressed: () => showScheduleCampDialog(
              context: context,
              selectedBankId: selectedBankId,
              onCampUpdated: onCampUpdated,
              onShowToast: onShowToast,
            ),
            icon: const Icon(Icons.add_circle_rounded,
                size: 28, color: BrandColors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoadingCamps
            ? const Center(
                child: CircularProgressIndicator(color: BrandColors.red))
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SpeechBubble(
                    emoji: '⛺',
                    text:
                        'Blood donation drives bring communities together. Organize camps and track donor RSVPs in Supabase!',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Camps in Supabase',
                              style: BrandTypography.title2(
                                  color: BrandColors.textPrimary)),
                          Text(
                              '${bankCamps.length} Drives Scheduled Across Regions',
                              style: BrandTypography.caption(
                                  color: BrandColors.red)),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () => showScheduleCampDialog(
                          context: context,
                          selectedBankId: selectedBankId,
                          onCampUpdated: onCampUpdated,
                          onShowToast: onShowToast,
                        ),
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: BrandColors.red),
                        label: const Text('Schedule Drive',
                            style: TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: BrandColors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: BrandColors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...bankCamps.map((camp) => BankCampCard(
                        camp: camp,
                        onCheckIn: () => showCampCheckInSheet(
                          context: context,
                          camp: camp,
                          onCampUpdated: onCampUpdated,
                          onShowToast: onShowToast,
                        ),
                        onRoster: () => showCampRosterSheet(
                          context: context,
                          camp: camp,
                        ),
                        onBroadcast: () => showBankBroadcastSheet(
                          context: context,
                          camp: camp,
                          onShowToast: onShowToast,
                        ),
                      )),
                ],
              ),
      ),
    );
  }
}
