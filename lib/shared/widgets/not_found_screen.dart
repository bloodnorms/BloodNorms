// ============================================================================
// BloodNorms | not_found_screen.dart
// 404 Page Not Found — Clean, minimal light theme
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';
import 'app_pill_button.dart';
import 'screen_header.dart';
import 'speech_bubble.dart';

class NotFoundScreen extends StatelessWidget {
  final String? error;

  const NotFoundScreen({
    super.key,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: const ScreenHeader(
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
                const SpeechBubble(
                  emoji: '🧭',
                  text: 'Oops! Looks like this page wandered off the grid. Don\'t worry, every heartbeat still counts!',
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: BrandColors.surface,
                    borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                    boxShadow: BrandColors.shadowSubtle,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: BrandColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                          border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                        ),
                        child: const Text(
                          'ERROR 404',
                          style: TextStyle(
                            fontFamily: BrandTypography.fontFamily,
                            color: BrandColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Page Not Found',
                        style: BrandTypography.title1(color: BrandColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The screen or resource you are looking for does not exist or may have been relocated.',
                        style: BrandTypography.body(color: BrandColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      if (error != null && error!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BrandColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                            border: Border.all(color: BrandColors.borderSubtle),
                          ),
                          child: Text(
                            error!,
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 11,
                              color: BrandColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      AppPillButton(
                        text: 'Return to Home',
                        icon: Icons.home_rounded,
                        variant: AppPillButtonVariant.primary,
                        height: 48,
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(height: 12),
                      AppPillButton(
                        text: 'Emergency Blood Directory',
                        icon: Icons.local_hospital_rounded,
                        variant: AppPillButtonVariant.secondary,
                        height: 48,
                        onPressed: () => context.go('/b'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Need urgent blood right now? Call 24x7 Helpline +91 883 247 1234',
                  style: BrandTypography.caption(color: BrandColors.textSecondary),
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
