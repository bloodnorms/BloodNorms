// ============================================================================
// BloodNorms | home_screen.dart
// Requester Home Screen — Original, Clean & Human-Centered Healthcare Design
// Designed for crisis clarity: Low cognitive load, immediate reassurance
// Layout faithfully matches specification:
// Top Bar: Left Menu (3 lines), Center "BloodNorms" (bold Arial), Right Language pill
// Hero Card: "Need blood right now?", blood bag graphic, white "Find Blood Now" button
// Immediate Assistance: WhatsApp & Call Helpline
// Action Grid: Side-by-side "Become a Donor" & "Find Blood Camps" cards
// Advisory Card: Voluntary & free notice with chevron
// Real-time Platform Stats: Live counts from Supabase (Donors, Centers, Camps)
// Campaign Banner: Voluntary Blood Donation Day awareness
// Strict rules: Arial font only, FontWeight.normal & FontWeight.bold only.
// Primary color: Cardinal Red (#E52E2E). Universal Green for success/callouts.
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_typography.dart';
import '../providers/request_flow_provider.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onLocaleChanged,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _registeredDonors = 5;
  int _bloodCenters = 5;
  int _campsOrganised = 3;
  bool _isLoadingStats = true;

  Map<String, dynamic>? _activeRequest;
  StreamSubscription? _activeRequestSub;

  @override
  void initState() {
    super.initState();
    _loadLiveStats();
    _checkActiveRequest();
  }

  Future<void> _checkActiveRequest() async {
    final activeId = await globalRequestFlow.loadActiveRequestIdFromStorage();
    if (activeId != null && activeId.isNotEmpty) {
      final req = await SupabaseService().getRequest(activeId);
      if (mounted && req != null) {
        setState(() {
          _activeRequest = req;
        });

        if (req['status'] == 'searching') {
          _activeRequestSub = SupabaseService().streamRequest(activeId).listen((row) {
            if (!mounted || row == null) return;
            setState(() {
              _activeRequest = row;
            });
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _activeRequestSub?.cancel();
    super.dispose();
  }

  Future<void> _loadLiveStats() async {
    try {
      final stats = await SupabaseService().getPlatformStats();
      if (mounted) {
        setState(() {
          _registeredDonors = stats['donors'] ?? 5;
          _bloodCenters = stats['banks'] ?? 5;
          _campsOrganised = stats['camps'] ?? 3;
          _isLoadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  void _stopActiveSearch(String reqId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE52E2E), width: 2.0),
        ),
        title: const Text(
          'Stop Search?',
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE52E2E),
          ),
        ),
        content: const Text(
          'This will cancel the active request in Supabase and notify contacted donors that blood is no longer needed.',
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 14,
            color: Color(0xFF4B5563),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('KEEP SEARCHING', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await SupabaseService().closeRequest(
                      reqId,
                      outcome: 'cancelled_by_requester',
                      status: 'cancelled',
                    );
                    globalRequestFlow.clearActiveRequestId();
                    setState(() {
                      _activeRequest = null;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Active blood request cancelled.'),
                          backgroundColor: Color(0xFFE52E2E),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52E2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('STOP', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: FontWeight.bold)),
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildTopAppBar(context, loc),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // 0. ACTIVE REQUEST CARD / CLOSED BANNER (If any)
            if (_activeRequest != null) ...[
              if (_activeRequest!['status'] == 'searching')
                _buildActiveEmergencyCard(context)
              else
                _buildClosedRequestBanner(context),
            ],

            // 1. HERO EMERGENCY CARD (Matches reference image)
            _buildHeroCard(context),
            const SizedBox(height: 16),

            // 2. IMMEDIATE ASSISTANCE CHANNELS: WhatsApp & Helpline Call
            _buildAssistanceRow(context),
            const SizedBox(height: 16),

            // 3. TWO SIDE-BY-SIDE CARDS: "Become a Donor" & "Find Blood Camps"
            _buildActionCardsRow(context),
            const SizedBox(height: 16),

            // 4. ADVISORY NOTICE (Demo / Trust status with chevron)
            _buildAdvisoryNotice(context),
            const SizedBox(height: 18),

            // 5. LIVE STATS COUNTER: Real dynamic metrics from Supabase
            _buildStatsRow(),
            const SizedBox(height: 20),

            // 6. VOLUNTARY DONATION CAMPAIGN BANNER
            _buildCampaignBanner(),
            const SizedBox(height: 20),

            // 7. PILOT STATUS & COVERAGE FOOTER
            _buildCoverageFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP APP BAR (Left 3-lines Menu, Center BloodNorms, Right Language)
  // ===========================================================================

  PreferredSizeWidget _buildTopAppBar(BuildContext context, AppLocalizations loc) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                // Left 3-lines menu icon button
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showNavigationMenu(context),
                  child: Container(
                    width: 42,
                    height: 42,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language_rounded,
                          size: 15,
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
  // 1.5 ACTIVE EMERGENCY SEARCH CARD & CLOSED BANNER
  // ===========================================================================

  Widget _buildActiveEmergencyCard(BuildContext context) {
    final req = _activeRequest!;
    final bg = req['blood_group']?.toString() ?? 'Blood';
    final units = (req['units_needed'] as num?)?.toInt() ?? 1;
    final hospital = req['hospital_name']?.toString() ?? 'Hospital';
    final contacted = (req['donors_contacted'] as num?)?.toInt() ?? 0;
    final agreed = (req['donors_accepted'] as num?)?.toInt() ?? 0;
    final ring = (req['current_ring_km'] as num?)?.toDouble() ?? 1.0;
    final id = req['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE52E2E), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5E7EB),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE52E2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ACTIVE SEARCH IN PROGRESS',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE52E2E),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE52E2E), width: 1.2),
                ),
                child: Text(
                  'RING: ${ring.toStringAsFixed(1)} KM',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE52E2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE52E2E), width: 2),
                ),
                child: Center(
                  child: Text(
                    bg,
                    style: const TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE52E2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$units ${units == 1 ? "Unit" : "Units"} $bg Needed',
                      style: const TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hospital,
                      style: const TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Contacted: $contacted',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const Text('•', style: TextStyle(color: Color(0xFFD1D5DB))),
                Text(
                  'Agreed: $agreed',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/live/$id'),
                  icon: const Icon(Icons.radar_rounded, size: 18),
                  label: const Text(
                    'VIEW LIVE MAP',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE52E2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => _stopActiveSearch(id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE52E2E),
                    side: const BorderSide(color: Color(0xFFE52E2E), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'STOP',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  Widget _buildClosedRequestBanner(BuildContext context) {
    final req = _activeRequest!;
    final isCancelled = req['status'] == 'cancelled';
    final hospital = req['hospital_name']?.toString() ?? 'Hospital';
    final outcome = req['outcome']?.toString() ?? (isCancelled ? 'Cancelled' : 'Completed');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled ? const Color(0xFFE52E2E) : const Color(0xFF10B981),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
            color: isCancelled ? const Color(0xFFE52E2E) : const Color(0xFF10B981),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCancelled ? 'Previous Request Cancelled' : 'Previous Request Fulfilled',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCancelled ? const Color(0xFFE52E2E) : const Color(0xFF10B981),
                  ),
                ),
                Text(
                  '$hospital ($outcome)',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    fontSize: 11.5,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              globalRequestFlow.clearActiveRequestId();
              setState(() => _activeRequest = null);
            },
            child: const Text(
              'DISMISS',
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. HERO EMERGENCY CARD (Matches user screenshot: red card + bag + white button)
  // ===========================================================================

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE52E2E),
            Color(0xFFC71D1D),
            Color(0xFFA11313),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE52E2E).withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Headline and subhead
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need blood\nright now?',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Get in touch with donors and blood banks near you, in minutes.',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.normal,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.38,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Column: Illustrated Blood Bag
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 130,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(80, 120),
                      painter: _BloodBagPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action Button: Clean prominent white button "⚡ Find Blood Now"
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (_activeRequest != null && _activeRequest!['status'] == 'searching') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text(
                        'Active Search in Progress',
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      content: Text(
                        'You currently have an active emergency blood search for ${_activeRequest!['blood_group']} at ${_activeRequest!['hospital_name']}.\n\nWould you like to continue tracking it, or start a new request?',
                        style: const TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          color: Color(0xFF4B5563),
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            globalRequestFlow.reset();
                            context.push('/group');
                          },
                          child: const Text(
                            'START NEW',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE52E2E),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.push('/live/${_activeRequest!['id']}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE52E2E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'VIEW ACTIVE',
                            style: TextStyle(
                              fontFamily: DuoTypography.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  context.push('/group');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFE52E2E),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Find Blood Now',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE52E2E),
                        letterSpacing: -0.2,
                      ),
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
  // 3. IMMEDIATE ASSISTANCE CHANNELS: WhatsApp & Call Helpline
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
              padding: const EdgeInsets.all(15),
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
                    width: 36,
                    height: 36,
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
                  const SizedBox(height: 10),
                  const Text(
                    'WhatsApp',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Chat directly to request',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11,
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
              padding: const EdgeInsets.all(15),
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
                    width: 36,
                    height: 36,
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
                  const SizedBox(height: 10),
                  const Text(
                    'Call Helpline',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '24/7 voice assistance',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11,
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
  // 4. TWO SIDE-BY-SIDE CARDS: "Become a Donor" & "Find Blood Camps"
  // ===========================================================================

  Widget _buildActionCardsRow(BuildContext context) {
    return Row(
      children: [
        // Left Card: Become a Donor
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/donor'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite_outline_rounded,
                      color: Color(0xFFE52E2E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Become a\nDonor',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Get matched to nearby requests',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Right Card: Find Blood Camps
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/donor/camps'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFE52E2E),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find Blood\nCamps',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Upcoming drives near you',
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 11.5,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF6B7280),
                      height: 1.3,
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
  // 5. ADVISORY NOTICE (Demo / Trust status matching screenshot)
  // ===========================================================================

  Widget _buildAdvisoryNotice(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showTrustModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFE52E2E),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'BloodNorms is ',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF374151),
                      ),
                    ),
                    TextSpan(
                      text: '100% voluntary & free',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    TextSpan(
                      text: '. Never pay any agent.',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. LIVE PLATFORM STATS COUNTER (Fetched dynamically from Supabase)
  // ===========================================================================

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            count: _isLoadingStats ? '...' : '$_registeredDonors',
            label: 'Registered Donors',
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE5E7EB),
          ),
          _buildStatColumn(
            count: _isLoadingStats ? '...' : '$_bloodCenters',
            label: 'Blood Centers',
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE5E7EB),
          ),
          _buildStatColumn(
            count: _isLoadingStats ? '...' : '$_campsOrganised',
            label: 'Camps Organised',
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({required String count, required String label}) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.normal,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 7. NATIONAL BLOOD DONATION CAMPAIGN BANNER (Matches screenshot bottom)
  // ===========================================================================

  Widget _buildCampaignBanner() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFBEB),
                Color(0xFFFEF3C7),
                Color(0xFFFDE68A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFCD34D), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🇮🇳', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'National Voluntary Blood Donation',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'One Drop of Humanity. Give Blood. Save Lives.',
                      style: TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Carousel indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE52E2E),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 8. COVERAGE FOOTER
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
  // 9. NAVIGATION MENU SHEET (Opens on 3-lines icon tap)
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
                      fontSize: 11.5,
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
  // 10. HELPER MODALS & LAUNCHERS
  // ===========================================================================

  void _showTrustModal(BuildContext context) {
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
              child: const Icon(Icons.verified_user_rounded, color: Color(0xFFE52E2E), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'The BloodNorms Pledge',
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• 100% Free & Voluntary: Blood donation in India is governed by the Drugs and Cosmetics Act. Selling or buying blood is illegal.\n\n'
              '• Verified Honest Stock: Blood banks report honest units directly.\n\n'
              '• Contact Shielding: Your number is shared only when a donor accepts your emergency request.',
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE52E2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'I Understand',
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
              'Choose Language / భాష / भाषा',
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            _buildLangTile(ctx, 'English', const Locale('en')),
            const SizedBox(height: 8),
            _buildLangTile(ctx, 'తెలుగు (Telugu)', const Locale('te')),
            const SizedBox(height: 8),
            _buildLangTile(ctx, 'हिंदी (Hindi)', const Locale('hi')),
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
        widget.onLocaleChanged(locale);
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

// ============================================================================
// BLOOD BAG CUSTOM PAINTER (Faithful rendering of the bag graphic in screenshot)
// ============================================================================

class _BloodBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBag = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final strokeBag = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final bloodPaint = Paint()
      ..color = const Color(0xFF880808)
      ..style = PaintingStyle.fill;

    final labelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final labelBorder = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final tubePaint = Paint()
      ..color = const Color(0xFF9E1212)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Outer Bag Rounded Rect
    final bagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 16, size.width - 20, size.height - 32),
      const Radius.circular(16),
    );

    // Inner Blood Fluid
    final bloodRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(13, 30, size.width - 26, size.height - 48),
      const Radius.circular(13),
    );

    canvas.drawRRect(bagRect, paintBag);
    canvas.drawRRect(bloodRect, bloodPaint);
    canvas.drawRRect(bagRect, strokeBag);

    // Top Eyelet Hole
    final eyeletPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 22), 4, eyeletPaint);

    // Label Card in Center
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 42, size.width - 40, 40),
      const Radius.circular(6),
    );
    canvas.drawRRect(labelRect, labelPaint);
    canvas.drawRRect(labelRect, labelBorder);

    // Blood drop icon on label
    final dropPaint = Paint()
      ..color = const Color(0xFFE52E2E)
      ..style = PaintingStyle.fill;
    final dropPath = Path();
    final cx = size.width / 2;
    dropPath.moveTo(cx, 48);
    dropPath.cubicTo(cx - 5, 54, cx - 7, 58, cx, 64);
    dropPath.cubicTo(cx + 7, 58, cx + 5, 54, cx, 48);
    canvas.drawPath(dropPath, dropPaint);

    // Barcode lines on label
    final barPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(26, 74), Offset(size.width - 26, 74), barPaint);

    // Bottom Tube hanging down
    final tubePath = Path();
    tubePath.moveTo(size.width / 2 + 6, size.height - 16);
    tubePath.cubicTo(
      size.width / 2 + 10,
      size.height,
      size.width / 2 + 25,
      size.height - 6,
      size.width / 2 + 20,
      size.height + 15,
    );
    canvas.drawPath(tubePath, tubePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
