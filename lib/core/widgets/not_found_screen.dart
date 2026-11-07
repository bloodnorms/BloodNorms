// ============================================================================
// BloodNorms | not_found_screen.dart
// 404 Page Not Found — Duolingo Feather Red Style
// Physical 3D paper card, mascot reassurance, Arial bold/normal only
// Cardinal Red (#E52E2E), Universal Green strictly for success
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/duo_colors.dart';
import '../theme/duo_typography.dart';
import 'duo_button.dart';
import 'duo_header_bar.dart';

class NotFoundScreen extends StatelessWidget {
  final String? error;

  const NotFoundScreen({
    super.key,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'BloodNorms',
        showBackButton: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mascot speech bubble
                const DuoSpeechBubble(
                  emoji: '🧭',
                  text: 'Oops! Looks like this page wandered off the grid. Don\'t worry, every heartbeat still counts!',
                ),
                const SizedBox(height: 28),

                // 3D Paper 404 Illustration Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: DuoColors.border, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: DuoColors.border,
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Large 404 Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: DuoColors.redTint,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: DuoColors.redShadow, width: 1.5),
                        ),
                        child: const Text(
                          'ERROR 404',
                          style: TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            color: DuoColors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'PAGE NOT FOUND',
                        style: DuoTypography.title1(color: DuoColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'The screen or resource you are looking for does not exist or may have been relocated.',
                        style: DuoTypography.body(color: DuoColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),

                      if (error != null && error!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: DuoColors.border),
                          ),
                          child: Text(
                            error!,
                            style: const TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              fontSize: 11,
                              color: DuoColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Navigation Actions
                      DuoButton(
                        label: 'RETURN TO HOME',
                        icon: Icons.home_rounded,
                        variant: DuoButtonVariant.primary,
                        height: 52,
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(height: 12),
                      DuoButton(
                        label: 'EMERGENCY BLOOD DIRECTORY',
                        icon: Icons.local_hospital_rounded,
                        variant: DuoButtonVariant.secondary,
                        height: 48,
                        onPressed: () => context.go('/b'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Need urgent blood right now? Call 24x7 Helpline +91 883 247 1234',
                  style: DuoTypography.caption(color: DuoColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

