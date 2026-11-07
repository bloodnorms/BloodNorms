// ============================================================================
// BloodNorms | donor_camps_screen.dart
// Blood Donation Camps Screen — Duolingo Feather Red Style
// 3D paper cards, date blocks, 3D Join/Leave actions, registered progress, Material
// ============================================================================

import 'package:flutter/material.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';

class DonorCampsScreen extends StatefulWidget {
  const DonorCampsScreen({super.key});

  @override
  State<DonorCampsScreen> createState() => _DonorCampsScreenState();
}

class _DonorCampsScreenState extends State<DonorCampsScreen> {
  final Set<String> _joinedCampIds = {};

  void _toggleJoin(String id) {
    setState(() {
      if (_joinedCampIds.contains(id)) {
        _joinedCampIds.remove(id);
      } else {
        _joinedCampIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Donation Camps',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const DuoSpeechBubble(
              emoji: '⛺',
              text: 'Join voluntary blood drives in your city! Meet fellow donors and save lives together.',
            ),
            const SizedBox(height: 20),
            Text('Upcoming Camps', style: DuoTypography.title1(color: DuoColors.textPrimary)),
            const SizedBox(height: 16),
            _buildDuoCampCard(
              id: 'c1',
              title: 'Mega Voluntary Blood Donation Camp',
              venue: 'Rotary Community Hall, Danavaipeta, Rajahmundry',
              month: 'NOV',
              day: '15',
              time: '09:00 AM – 04:00 PM',
              baseRegistered: 48,
              capacity: 100,
            ),
            const SizedBox(height: 16),
            _buildDuoCampCard(
              id: 'c2',
              title: 'Government College Campus Drive',
              venue: 'Auditorium, Arts College, Rajahmundry',
              month: 'NOV',
              day: '22',
              time: '10:00 AM – 02:00 PM',
              baseRegistered: 30,
              capacity: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuoCampCard({
    required String id,
    required String title,
    required String venue,
    required String month,
    required String day,
    required String time,
    required int baseRegistered,
    required int capacity,
  }) {
    final isJoined = _joinedCampIds.contains(id);
    final count = baseRegistered + (isJoined ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isJoined ? DuoColors.greenShadow : DuoColors.border,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Box in Red
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isJoined ? DuoColors.greenTint : DuoColors.redTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isJoined ? DuoColors.greenShadow : DuoColors.redShadow,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isJoined ? DuoColors.greenShadow : DuoColors.redShadow,
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      month,
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        color: isJoined ? DuoColors.green : DuoColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      day,
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        color: isJoined ? DuoColors.green : DuoColors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: DuoTypography.headline(color: DuoColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: DuoColors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue,
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 14, color: DuoColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(time, style: DuoTypography.caption(color: DuoColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Registered progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count donors registered ($capacity capacity)',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: DuoColors.textSecondary,
                ),
              ),
              if (isJoined)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: DuoColors.greenTint,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_rounded, size: 12, color: DuoColors.green),
                      SizedBox(width: 2),
                      Text('JOINED', style: TextStyle(color: DuoColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Join / Leave Button
          DuoButton(
            label: isJoined ? 'LEAVE CAMP' : 'JOIN BLOOD DRIVE',
            icon: isJoined ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
            height: 44,
            variant: isJoined ? DuoButtonVariant.secondary : DuoButtonVariant.primary,
            onPressed: () => _toggleJoin(id),
          ),
        ],
      ),
    );
  }
}
