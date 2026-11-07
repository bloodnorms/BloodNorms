// ============================================================================
// BloodNorms | broadcast_dispatch_view.dart
// Regional Broadcast Dispatch Workspace View
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

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
    final eligible = audiencePreview['eligible_count'] ?? 0;
    final suppressed = audiencePreview['suppressed_count'] ?? 0;
    final cost = audiencePreview['estimated_cost_inr'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target City',
                    border: OutlineInputBorder(),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Delivery Channel',
                    border: OutlineInputBorder(),
                  ),
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
            'Target Geofence Radius: ${broadcastRadiusKm.toInt()} km',
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Slider(
            value: broadcastRadiusKm,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            activeColor: BrandColors.red,
            onChanged: onRadiusChanged,
          ),
          SwitchListTile(
            dense: true,
            title: const Text(
              'Respect Donor Personal Travel Limits',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            subtitle: const Text(
              'Exclude donors whose preferred radius is less than this camp distance',
            ),
            value: respectDonorTravelRadius,
            activeThumbColor: BrandColors.red,
            onChanged: onRespectRadiusChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: broadcastTitleController,
            decoration: const InputDecoration(
              labelText: 'Broadcast Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: broadcastMsgController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message Body',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎯 Matched Audience: $eligible donors',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '🚫 Suppressed: $suppressed donors',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.textSecondary,
                  ),
                ),
                Text(
                  'Cost: ₹${cost.toStringAsFixed(2)} INR',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isBroadcasting ? null : onDispatch,
              icon: isBroadcasting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 16),
              label: const Text('Dispatch Regional Broadcast'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
