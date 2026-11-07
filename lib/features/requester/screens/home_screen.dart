// ============================================================================
// BloodNorms | home_screen.dart
// Requester Home Screen — Original, Clean & Human-Centered Healthcare Design
// Designed for crisis clarity: Low cognitive load, immediate trust & high reassurance
// Top Bar: Left Menu (3 lines), Center "BloodNorms" (bold Arial), Right Language
// Core: Instant Emergency Request, WhatsApp & Voice Helpline, Donor & Bank gateways,
// BloodNorms Triad of Trust (Fast, Real, Safe - PRD §1). Zero unwanted clutter.
// Strict rules: Arial font only, FontWeight.normal & FontWeight.bold only.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/duo_typography.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onLocaleChanged,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildTopAppBar(context, loc),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // -----------------------------------------------------------------
            // 1. BESPOKE HERO BANNER: Direct Emergency Gateway
            // -----------------------------------------------------------------
            _buildHeroSection(context),
            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // 2. IMMEDIATE ASSISTANCE CHANNELS: WhatsApp & Helpline Call
            // -----------------------------------------------------------------
            _buildAssistanceRow(context),
            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // 3. ESSENTIAL SERVICES: "Become a Donor" & "Blood Banks Directory"
            // -----------------------------------------------------------------
            _buildServicesSection(context),
            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // 4. THE BLOODNORMS GUARANTEE: Real, Fast, 100% Free
            // -----------------------------------------------------------------
            _buildTrustPledge(context),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // 5. PILOT STATUS & COVERAGE FOOTER
            // -----------------------------------------------------------------
            _buildCoverageFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP APP BAR
  // ===========================================================================

  PreferredSizeWidget _buildTopAppBar(BuildContext context, AppLocalizations loc) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.0),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Left 3-lines menu icon button
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showNavigationMenu(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.menu_rounded,
                        size: 22,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),

                // Center Title: BloodNorms in bold Arial
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE52E2E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          AppConstants.appName,
                          style: const TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Language Selection Pill
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showLanguageModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          size: 16,
                          color: Color(0xFFE52E2E),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          loc.locale.languageCode.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: DuoTypography.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HERO SECTION: Clear Emergency Search Gateway
  // ===========================================================================

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE52E2E),
            Color(0xFFC61C1C),
            Color(0xFF9E1212),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE52E2E).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency status tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Verified Emergency Network',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Core Headline
          const Text(
            'Find blood\nin minutes.',
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.8,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),

          // Reassurance copy
          Text(
            'Nearest honest blood bank stock first. Then verified, consenting local donors near your hospital.',
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),

          // Action Button: Crisp White Pill
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push('/group'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFFE52E2E),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Request Blood Now',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE52E2E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFE52E2E),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TWO IMMEDIATE ASSISTANCE CHANNELS: WhatsApp & Call 108
  // ===========================================================================

  Widget _buildAssistanceRow(BuildContext context) {
    return Row(
      children: [
        // WhatsApp Channel Card
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _launchWhatsApp(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chat_rounded,
                      color: Color(0xFF16A34A),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'WhatsApp',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Chat directly to request',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Emergency Call Card
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _makeHelplineCall(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Call Helpline',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '24/7 voice assistance',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TWO CORE PLATFORM ROLES: Donor Gateway & Bank Directory
  // ===========================================================================

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      children: [
        // Donor Card
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/donor'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE52E2E),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Become a Verified Donor',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Get contacted only when an exact match nearby needs you.',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Blood Banks Card
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/b'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check Blood Banks Stock',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'View honest stock & availability before traveling.',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BLOODNORMS TRIAD OF TRUST (Fast · Real · Safe)
  // ===========================================================================

  Widget _buildTrustPledge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFFE52E2E),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'The BloodNorms Promise',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildPromiseRow(
            icon: Icons.bolt_rounded,
            title: 'Minutes, Not Hours',
            description: 'First eligible donors and banks are contacted in seconds.',
          ),
          const SizedBox(height: 10),
          _buildPromiseRow(
            icon: Icons.check_circle_rounded,
            title: 'Verified & Honest',
            description: 'Strict medical gap rules (BR-02) and verified donors only.',
          ),
          const SizedBox(height: 10),
          _buildPromiseRow(
            icon: Icons.lock_rounded,
            title: '100% Free & Private',
            description: 'Never pay for blood. Phone numbers are shielded until accepted.',
          ),
        ],
      ),
    );
  }

  Widget _buildPromiseRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE52E2E)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // COVERAGE FOOTER
  // ===========================================================================

  Widget _buildCoverageFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFE52E2E)),
                SizedBox(width: 6),
                Text(
                  'Live Pilot: Rajahmundry & Kakinada (AP)',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'BloodNorms is non-commercial. We never ask for OTP or money.',
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.normal,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // NAVIGATION MENU SHEET (Hiding Bank Staff & Admin into menu)
  // ===========================================================================

  void _showNavigationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BloodNorms Navigation',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF9CA3AF)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 10),

              // Platform Services
              const Text(
                'SERVICES',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              _buildNavTile(
                ctx,
                icon: Icons.water_drop_rounded,
                title: 'Request Blood',
                subtitle: 'Emergency multi-wave search',
                route: '/group',
              ),
              _buildNavTile(
                ctx,
                icon: Icons.favorite_rounded,
                title: 'Become a Donor',
                subtitle: 'Register & save lives locally',
                route: '/donor',
              ),
              _buildNavTile(
                ctx,
                icon: Icons.local_hospital_rounded,
                title: 'Blood Banks Directory',
                subtitle: 'Live stock & contact details',
                route: '/b',
              ),
              _buildNavTile(
                ctx,
                icon: Icons.campaign_rounded,
                title: 'Donation Camps',
                subtitle: 'Upcoming local blood drives',
                route: '/donor/camps',
              ),
              _buildNavTile(
                ctx,
                icon: Icons.badge_rounded,
                title: 'My Donor Pass',
                subtitle: 'View your digital donor card',
                route: '/donor/profile',
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 10),

              // Management Consoles (Hidden from Home Screen)
              const Text(
                'MANAGEMENT CONSOLES',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              _buildNavTile(
                ctx,
                icon: Icons.business_rounded,
                title: 'Blood Bank Console',
                subtitle: 'Stock update & code confirmation',
                route: '/bank',
              ),
              _buildNavTile(
                ctx,
                icon: Icons.shield_rounded,
                title: 'Super Admin Console',
                subtitle: 'Live waves, kill switch & audit trail',
                route: '/admin',
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.pop(ctx);
        ctx.push(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFE52E2E), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // MODALS & CONTACT HANDLERS
  // ===========================================================================

  void _showLanguageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language / భాష / भाषा',
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            _buildLangTile(ctx, 'English (EN)', const Locale('en')),
            const SizedBox(height: 8),
            _buildLangTile(ctx, 'తెలుగు (TE)', const Locale('te')),
            const SizedBox(height: 8),
            _buildLangTile(ctx, 'हिन्दी (HI)', const Locale('hi')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTile(BuildContext ctx, String label, Locale locale) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        onLocaleChanged(locale);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xFFE52E2E)),
          ],
        ),
      ),
    );
  }

  Future<void> _makeHelplineCall(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE8E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_in_talk_rounded,
                color: Color(0xFFE52E2E),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Emergency Voice Call',
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: const Text(
          'Select an immediate assistance channel:\n\n'
          '• 108 — National Emergency Ambulance\n'
          '• BloodNorms Helpline — 24/7 Verified Blood Desk',
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Color(0xFF4B5563),
            height: 1.45,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52E2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse('tel:108');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: const Text(
                    'Call 108',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final uri = Uri.parse('tel:+918832471234');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: const Text(
                    'Desk Helpline',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/918832471234?text=Hi');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_rounded, color: Color(0xFF16A34A), size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'WhatsApp Assistant',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          content: const Text(
            'Official WhatsApp Bot: +91 88324 71234\n\nChat with BloodNorms directly on WhatsApp to find blood in minutes or register as a donor.',
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Got It',
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
