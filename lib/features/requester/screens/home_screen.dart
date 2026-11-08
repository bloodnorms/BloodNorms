// ============================================================================
// BloodNorms | home_screen.dart
// Requester Home Screen — Original, Clean & Human-Centered Healthcare Design
// Designed for crisis clarity: Low cognitive load, immediate reassurance
// Thin screen composing modular feature widgets
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/index.dart';

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
          _activeRequestSub =
              SupabaseService().streamRequest(activeId).listen((row) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: HomeTopBar(
        onOpenMenu: () => HomeNavigationDrawer.show(context),
        onOpenLanguageModal: () => HomeNavigationDrawer.showLanguageModal(
          context,
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // 0. Active Emergency Card or Closed Request Banner
            if (_activeRequest != null) ...[
              if (_activeRequest!['status'] == 'searching')
                ActiveEmergencyCard(
                  activeRequest: _activeRequest!,
                  onSearchStopped: () {
                    setState(() => _activeRequest = null);
                  },
                )
              else
                ClosedRequestBanner(
                  activeRequest: _activeRequest!,
                  onDismiss: () {
                    globalRequestFlow.clearActiveRequestId();
                    setState(() => _activeRequest = null);
                  },
                ),
            ],

            // 1. Hero Emergency Card
            HeroCard(activeRequest: _activeRequest),
            const SizedBox(height: 16),

            // 2. Immediate Assistance: WhatsApp & Helpline Call
            const ImmediateAssistanceRow(),
            const SizedBox(height: 16),

            // 3. Side-by-side: "Become a Donor" & "Find Blood Camps"
            const ActionCardsRow(),
            const SizedBox(height: 16),

            // 4. Voluntary & Free Advisory Notice
            const AdvisoryNoticeCard(),
            const SizedBox(height: 18),

            // 5. Live Stats Counter
            PlatformStatsCard(
              registeredDonors: _registeredDonors,
              bloodCenters: _bloodCenters,
              campsOrganised: _campsOrganised,
              isLoading: _isLoadingStats,
            ),
            const SizedBox(height: 20),

            // 6 & 7. Voluntary Campaign Banner & Regional Pilot Footer
            const CampaignAndCoverageFooter(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
