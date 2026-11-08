// ============================================================================
// BloodNorms | donor_alerts_screen.dart
// Donor Alerts Tab — Thin Screen Composing Alert and History Cards
// Connected to Supabase requests table for real emergency dispatch alerts
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/speech_bubble.dart';
import '../widgets/donor_alert_card.dart';
import '../widgets/donor_history_card.dart';

class DonorAlertsScreen extends StatefulWidget {
  const DonorAlertsScreen({super.key});

  @override
  State<DonorAlertsScreen> createState() => _DonorAlertsScreenState();
}

class _DonorAlertsScreenState extends State<DonorAlertsScreen> {
  List<RequestAlertModel> _alerts = [];
  List<Map<String, dynamic>> _pastHistory = [];
  bool _isLoading = true;
  String? _acceptingId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final donorId = prefs.getString('current_donor_id');

    final results = await SupabaseService().getDonorAlerts();
    final history = (donorId != null && donorId.isNotEmpty)
        ? await SupabaseService().getDonorPastHistory(donorId)
        : <Map<String, dynamic>>[];

    if (mounted) {
      setState(() {
        _alerts = results;
        _pastHistory = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAccept(RequestAlertModel alert) async {
    final prefs = await SharedPreferences.getInstance();
    final donorId = prefs.getString('current_donor_id');

    if (donorId == null || donorId.isEmpty) {
      if (mounted) context.push('/donor/onboarding');
      return;
    }

    setState(() => _acceptingId = alert.id);

    await SupabaseService().acceptDonorAlert(
      requestId: alert.id,
      donorId: donorId,
    );

    if (mounted) {
      setState(() => _acceptingId = null);
      context.push('/donor/ticket/${alert.id}');
    }
  }

  void _handleDecline(String alertId) {
    setState(() {
      _alerts.removeWhere((a) => a.id == alertId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert declined. You will not be contacted for this request.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: const ScreenHeader(
        title: 'Emergency Alerts',
        showBackButton: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: BrandColors.primaryAction,
          onRefresh: _loadAll,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const SpeechBubble(
                emoji: '🚨',
                text: 'Emergency requests incoming. Check hospital distance and tap Accept if you can donate.',
              ),
              const SizedBox(height: 20),
              Text('Live Alerts', style: BrandTypography.title(color: BrandColors.textPrimary)),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: BrandColors.primaryAction),
                  ),
                )
              else if (_alerts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BrandColors.background,
                    borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                    border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.shield_outlined, size: 40, color: BrandColors.statusSuccess),
                        const SizedBox(height: 12),
                        Text('No Emergency Alerts Nearby', style: BrandTypography.title2(color: BrandColors.textPrimary)),
                        const SizedBox(height: 6),
                        Text(
                          'You will be notified immediately when a patient in Rajahmundry needs your blood group.',
                          style: BrandTypography.caption(color: BrandColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._alerts.map((alert) {
                  return DonorAlertCard(
                    alert: alert,
                    isAccepting: _acceptingId == alert.id,
                    onAccept: () => _handleAccept(alert),
                    onDecline: () => _handleDecline(alert.id),
                  );
                }),
              const SizedBox(height: 16),
              Text('Past Donations & Passes', style: BrandTypography.title3(color: BrandColors.textPrimary)),
              const SizedBox(height: 12),
              if (_pastHistory.isEmpty)
                const DonorEmptyHistoryCard()
              else
                ..._pastHistory.map((item) {
                  final req = item['requests'] as Map<String, dynamic>? ?? {};
                  final hosp = req['hospital_name']?.toString() ?? 'Blood Bank / Hospital';
                  final code = item['code'] ?? item['donation_code'] ?? '';
                  final date = (item['confirmed_at'] ?? item['accepted_at'] ?? '').toString();
                  final displayDate = date.length >= 10 ? date.substring(0, 10) : 'Recent';
                  final group = item['blood_group'] ?? req['blood_group'] ?? 'Blood';
                  final status = (item['status'] ?? 'DONATED').toString().toUpperCase();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DonorHistoryCard(
                      hospital: hosp,
                      date: '$displayDate • Code #$code',
                      group: '$group',
                      status: status,
                      statusColor: BrandColors.statusSuccess,
                      statusBg: BrandColors.statusSuccessTint,
                      statusBorder: BrandColors.borderSubtle,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
