// ============================================================================
// BloodNorms | donor_alerts_screen.dart
// Donor Alerts Tab — Duolingo Feather Red Style
// Connected to Supabase requests table for real emergency dispatch alerts
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';

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
    final donorId = prefs.getString('current_donor_id') ?? 'd1000000-0000-0000-0000-000000000001';

    final results = await SupabaseService().getDonorAlerts();
    final history = await SupabaseService().getDonorPastHistory(donorId);

    if (mounted) {
      setState(() {
        _alerts = results;
        _pastHistory = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAccept(RequestAlertModel alert) async {
    setState(() => _acceptingId = alert.id);
    final prefs = await SharedPreferences.getInstance();
    final donorId = prefs.getString('current_donor_id') ?? 'd1000000-0000-0000-0000-000000000001';

    await SupabaseService().acceptDonorAlert(
      requestId: alert.id,
      donorId: donorId,
    );

    if (mounted) {
      setState(() => _acceptingId = null);
      context.push('/donor/ticket/${alert.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Emergency Alerts',
        showBackButton: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: DuoColors.red,
          onRefresh: _loadAll,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Mascot Speech Bubble
              const DuoSpeechBubble(
                emoji: '🚨',
                text: 'Emergency requests incoming! Check hospital distance and tap ACCEPT if you can donate.',
              ),
              const SizedBox(height: 20),

              Text('Live Alerts', style: DuoTypography.title1(color: DuoColors.textPrimary)),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: DuoColors.red),
                  ),
                )
              else if (_alerts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: DuoColors.border, width: 2.0),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🛡️', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No Emergency Alerts Nearby', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                        const SizedBox(height: 6),
                        Text(
                          'You will be notified immediately when a patient in Rajahmundry needs your blood group.',
                          style: DuoTypography.caption(color: DuoColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._alerts.map((alert) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: DuoColors.redShadow, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: DuoColors.redShadow,
                            offset: Offset(0, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: DuoColors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  alert.urgency == 'now' ? 'URGENT NOW' : 'WITHIN 24H',
                                  style: const TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: DuoColors.redTint,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: DuoColors.redShadow, width: 1.5),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.location_on_rounded, size: 14, color: DuoColors.red),
                                    SizedBox(width: 4),
                                    Text(
                                      'RAJAHMUNDRY',
                                      style: TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        color: DuoColors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(alert.hospitalName, style: DuoTypography.title2(color: DuoColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(
                            '${alert.unitsNeeded} Unit ${alert.bloodGroup} ${alert.component.replaceAll('_', ' ')} needed for patient (${alert.patientFirstName})',
                            style: DuoTypography.body(color: DuoColors.textPrimary),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: DuoButton(
                                  label: _acceptingId == alert.id ? 'ACCEPTING...' : 'ACCEPT',
                                  icon: Icons.check_circle_rounded,
                                  variant: DuoButtonVariant.success,
                                  height: 48,
                                  onPressed: _acceptingId != null ? null : () => _handleAccept(alert),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DuoButton(
                                  label: 'DECLINE',
                                  variant: DuoButtonVariant.secondary,
                                  height: 48,
                                  onPressed: () {
                                    setState(() {
                                      _alerts.removeWhere((a) => a.id == alert.id);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Alert declined. You will not be contacted for this request.'),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 12),
              Text('Past Donations & Passes', style: DuoTypography.title3(color: DuoColors.textPrimary)),
              const SizedBox(height: 12),
              if (_pastHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DuoColors.border, width: 2.0),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.history_rounded, size: 36, color: DuoColors.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          'No Past Donations Yet',
                          style: DuoTypography.headline(color: DuoColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'When you complete a donation at a hospital or blood bank, your verified record will appear here.',
                          style: DuoTypography.caption(color: DuoColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
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
                    child: _buildPastAlertCard(
                      hospital: hosp,
                      date: '$displayDate • Code #$code',
                      group: '$group',
                      status: status,
                      statusColor: DuoColors.green,
                      statusBg: DuoColors.greenTint,
                      statusBorder: DuoColors.greenShadow,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPastAlertCard({
    required String hospital,
    required String date,
    required String group,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required Color statusBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DuoColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital, style: DuoTypography.title3(color: DuoColors.textPrimary)),
                const SizedBox(height: 4),
                Text('$date • $group Whole Blood', style: DuoTypography.caption(color: DuoColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusBorder, width: 1.5),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
