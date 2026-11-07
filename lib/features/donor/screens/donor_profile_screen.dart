// ============================================================================
// BloodNorms | donor_profile_screen.dart
// Donor Profile Screen — Duolingo Feather Red Style
// 3D paper cards, mascot speech bubble, gamified badges, privacy tools, Material
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({super.key});

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuoColors.redTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DuoColors.redShadow, width: 1.5),
              ),
              child: const Icon(Icons.description_rounded, color: DuoColors.red, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Export Complete', style: DuoTypography.title3(color: DuoColors.textPrimary)),
          ],
        ),
        content: Text(
          'Your personal donor data has been securely prepared as JSON in compliance with DPDP Act rights.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          DuoButton(
            label: 'DONE',
            height: 44,
            variant: DuoButtonVariant.success,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuoColors.redTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DuoColors.redShadow, width: 1.5),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: DuoColors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Delete Account?', style: DuoTypography.title3(color: DuoColors.red)),
          ],
        ),
        content: Text(
          'This will permanently delete your donor account, encrypted health records, contact information, and remove you from emergency matching. This action cannot be undone.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  label: 'CANCEL',
                  height: 44,
                  variant: DuoButtonVariant.secondary,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DuoButton(
                  label: 'DELETE',
                  height: 44,
                  variant: DuoButtonVariant.destructive,
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Mascot Speech Bubble
            const DuoSpeechBubble(
              emoji: '🩸',
              text: 'Every donation can save up to three lives. Check your badges and keep your health questions fresh!',
            ),
            const SizedBox(height: 20),

            // Profile Card with 3D bottom bevel
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DuoColors.border, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: DuoColors.border,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with 3D border
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: DuoColors.redTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: DuoColors.redShadow, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: DuoColors.border,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'R',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          color: DuoColors.red,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ramesh Varma', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('+91 98481 23456', style: DuoTypography.subhead(color: DuoColors.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: DuoColors.red,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: DuoColors.redShadow,
                                    offset: Offset(0, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'O Positive',
                                style: TextStyle(
                                  fontFamily: DuoTypography.fontFamily,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('28 yrs · 68 kg', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hero Gamification Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildDuoStatCard(
                    icon: '🔥',
                    value: '3 Days',
                    label: 'STREAK',
                    borderColor: DuoColors.redShadow,
                    bgColor: DuoColors.redTint,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDuoStatCard(
                    icon: '💎',
                    value: '85',
                    label: 'TRUST',
                    borderColor: DuoColors.border,
                    bgColor: const Color(0xFFF7F7F7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDuoStatCard(
                    icon: '❤️',
                    value: '2',
                    label: 'LIVES',
                    borderColor: DuoColors.redShadow,
                    bgColor: DuoColors.redTint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Onboarding Wizard 3D Tile
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: DuoColors.border, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: DuoColors.border,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.push('/donor/onboarding'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: DuoColors.redTint,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: DuoColors.redShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.badge_rounded, color: DuoColors.red, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Donor Onboarding Wizard', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Complete 8-step registration test', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: DuoColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Privacy & Data Rights
            Text('Privacy & Data Rights', style: DuoTypography.title3(color: DuoColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      onTap: () => _exportData(context),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: DuoColors.redTint,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: DuoColors.redShadow, width: 1.5),
                              ),
                              child: const Icon(Icons.description_rounded, color: DuoColors.red, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Export My Data (JSON)', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('Download copy of personal records (DPDP Act)', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, size: 18, color: DuoColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: DuoColors.border),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DuoColors.greenTint,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: DuoColors.greenShadow, width: 1.5),
                          ),
                          child: const Icon(Icons.favorite_rounded, color: DuoColors.green, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Health Quick-Check', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('Verified · Due in 5 months', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: DuoColors.greenTint,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                          ),
                          child: const Text('OK', style: TextStyle(color: DuoColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3D Destructive Delete Button
            DuoButton(
              label: 'DELETE MY ACCOUNT',
              icon: Icons.delete_forever_rounded,
              variant: DuoButtonVariant.destructive,
              onPressed: () => _confirmDelete(context),
            ),
            const SizedBox(height: 16),

            // Sign Out
            DuoButton(
              label: 'SIGN OUT',
              variant: DuoButtonVariant.secondary,
              onPressed: () => context.go('/'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDuoStatCard({
    required String icon,
    required String value,
    required String label,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DuoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: DuoColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
