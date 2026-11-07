// ============================================================================
// BloodNorms | broadcast_dispatch_view.dart
// Modern Minimal Regional Broadcast Dispatch Workspace View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import 'broadcast_audience_summary_banner.dart';

export 'broadcast_audience_summary_banner.dart';

class BroadcastDispatchView extends StatelessWidget {
  final Map<String, dynamic> audiencePreview;
  final String selectedTargetCity;
  final String selectedChannel;
  final double broadcastRadiusKm;
  final bool respectDonorTravelRadius;
  final TextEditingController broadcastTitleController;
  final TextEditingController broadcastMsgController;
  final bool isBroadcasting;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onChannelChanged;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<bool> onRespectRadiusChanged;
  final VoidCallback onDispatch;

  const BroadcastDispatchView({
    super.key,
    required this.audiencePreview,
    required this.selectedTargetCity,
    required this.selectedChannel,
    required this.broadcastRadiusKm,
    required this.respectDonorTravelRadius,
    required this.broadcastTitleController,
    required this.broadcastMsgController,
    required this.isBroadcasting,
    required this.onCityChanged,
    required this.onChannelChanged,
    required this.onRadiusChanged,
    required this.onRespectRadiusChanged,
    required this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    final eligible = (audiencePreview['eligible_count'] as num?)?.toInt() ?? 0;
    final suppressed = (audiencePreview['suppressed_count'] as num?)?.toInt() ?? 0;
    final cost = (audiencePreview['estimated_cost_inr'] as num?)?.toDouble() ?? 0.0;

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
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Target city'),
                  initialValue: selectedTargetCity,
                  items: ['Rajahmundry', 'Kakinada', 'Vijayawada', 'Visakhapatnam']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) onCityChanged(val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Delivery channel'),
                  initialValue: selectedChannel,
                  items: const [
                    DropdownMenuItem(
                      value: 'whatsapp',
                      child: Text('WhatsApp Business (Meta)'),
                    ),
                    DropdownMenuItem(
                      value: 'sms',
                      child: Text('SMS Broadcast (Twilio)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) onChannelChanged(val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Target radius: ${broadcastRadiusKm.toInt()} km',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: BrandColors.textPrimary,
            ),
          ),
          Slider(
            value: broadcastRadiusKm,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            activeColor: BrandColors.primaryAction,
            inactiveColor: BrandColors.surfaceMuted,
            onChanged: onRadiusChanged,
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Respect donor travel preferences',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: BrandColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Exclude donors whose radius preference is lower than this distance',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontSize: 12,
                color: BrandColors.textSecondary,
              ),
            ),
            value: respectDonorTravelRadius,
            activeThumbColor: BrandColors.primaryAction,
            onChanged: onRespectRadiusChanged,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: broadcastTitleController,
            decoration: const InputDecoration(
              labelText: 'Campaign title',
              hintText: 'e.g. Urgent O+ Donors Needed at GSL Hospital',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: broadcastMsgController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message body',
              hintText: 'Type your message to eligible in-radius donors...',
            ),
          ),
          const SizedBox(height: 16),
          BroadcastAudienceSummaryBanner(
            eligible: eligible,
            suppressed: suppressed,
            cost: cost,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppPillButton(
              label: 'Dispatch broadcast',
              icon: Icons.send_rounded,
              variant: AppPillButtonVariant.primary,
              isLoading: isBroadcasting,
              onPressed: isBroadcasting ? null : onDispatch,
            ),
          ),
        ],
      ),
    );
  }
}
