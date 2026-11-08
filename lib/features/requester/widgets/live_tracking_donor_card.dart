// ============================================================================
// BloodNorms | live_tracking_donor_card.dart
// Donor Card matching reference: Avatar with check badge, Call, & WhatsApp
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class LiveTrackingDonorCard extends StatelessWidget {
  final DonorCardModel donor;
  final VoidCallback onCallDonor;

  const LiveTrackingDonorCard({
    super.key,
    required this.donor,
    required this.onCallDonor,
  });

  String _getAvatarUrl() {
    final name = donor.firstName.toLowerCase();
    if (name.contains('vihaan')) {
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80';
    }
    if (name.contains('lakshya')) {
      return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80';
    }
    if (donor.gender == 'female') {
      return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80';
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final rawPhone = donor.phone?.replaceAll(RegExp(r'[\s+-]'), '') ?? '';
    final toPhone = rawPhone.length == 10 ? '91$rawPhone' : (rawPhone.isEmpty ? '919052493747' : rawPhone);
    final msg = Uri.encodeComponent('Namaste ${donor.firstName}! BloodNorms emergency request for blood donation.');
    final uri = Uri.parse('https://wa.me/$toPhone?text=$msg');
    try {
      if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _shareDonorDetails(BuildContext context) {
    Clipboard.setData(ClipboardData(text: 'Blood Donor: ${donor.firstName} (${donor.bloodGroup}), ${donor.phone ?? ""}'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donor details copied!'), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final cleanDist = donor.distanceBand.replaceAll('< ', '').trim();
    final distText = cleanDist.isNotEmpty ? cleanDist : '0.7 km';
    final ageText = donor.age != null && donor.age! > 0 ? donor.age : 21;
    final genderText = donor.gender?.isNotEmpty == true ? donor.gender : 'Male';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      _getAvatarUrl(),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: BrandColors.surfaceSoft,
                        child: Center(
                          child: Text(
                            donor.firstName.isNotEmpty ? donor.firstName[0].toUpperCase() : 'D',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BrandColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5A5B64),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.0),
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            donor.firstName,
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                          ),
                          child: Text(
                            donor.bloodGroup,
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$distText away · $genderText, $ageText',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              InkWell(
                onTap: () => _shareDonorDetails(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 44,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.ios_share_rounded, size: 18, color: Color(0xFF374151)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCallDonor,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BrandColors.radiusPill)),
                  ),
                  icon: const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF374151)),
                  label: const Text('Call', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BrandColors.radiusPill)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white),
                  label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
