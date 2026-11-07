// ============================================================================
// BloodNorms | donor_home_screen.dart
// Donor Home Dashboard — Duolingo Feather Red Style
// DuoBottomNavBar, streak flame, hearts, 3D paper cards, Material Icons
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_bottom_nav_bar.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_meter.dart';
import 'donor_alerts_screen.dart';
import 'donor_camps_screen.dart';
import 'donor_profile_screen.dart';

class DonorHomeScreen extends StatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  int _currentTabIndex = 0;
  bool _isAvailable = true;
  int _donationsCount = 0;
  String? _donorId;
  String _donorName = 'Donor';
  String _donorGroup = 'O+';
  String? _latestRequestId;
  String _latestRequestHospital = 'GGH Rajahmundry';
  String _latestRequestGroup = 'O+';

  @override
  void initState() {
    super.initState();
    _loadDonorStats();
  }

  Future<void> _loadDonorStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dId = prefs.getString('current_donor_id');
      _donorId = dId;

      if (dId != null && dId.isNotEmpty) {
        final donorData = await SupabaseService().getDonor(dId);
        if (donorData != null && mounted) {
          setState(() {
            _donorName = donorData['full_name'] ?? donorData['first_name'] ?? 'Donor';
            _donorGroup = donorData['blood_group'] ?? 'O+';
            _isAvailable = (donorData['state'] != 'paused');
            _donationsCount = (donorData['donations_count'] as num?)?.toInt() ?? 0;
          });
        }
      } else {
        final allDonors = await SupabaseService().getAllDonors();
        if (allDonors.isNotEmpty && mounted) {
          final d = allDonors.first;
          _donorId = d['id']?.toString();
          setState(() {
            _donorName = d['full_name'] ?? d['first_name'] ?? 'Donor';
            _donorGroup = d['blood_group'] ?? 'O+';
            _isAvailable = (d['state'] != 'paused');
            _donationsCount = (d['donations_count'] as num?)?.toInt() ?? 0;
          });
        }
      }

      final alerts = await SupabaseService().getDonorAlerts(bloodGroup: _donorGroup);
      if (alerts.isNotEmpty && mounted) {
        final first = alerts.first;
        setState(() {
          _latestRequestId = first.id;
          _latestRequestHospital = first.hospitalName;
          _latestRequestGroup = first.bloodGroup;
        });
      }
    } catch (e) {
      debugPrint('Error loading donor stats: $e');
    }
  }

  Future<void> _toggleAvailability(bool val) async {
    setState(() => _isAvailable = val);
    if (_donorId != null) {
      await SupabaseService().updateDonorState(_donorId!, val ? 'active' : 'paused');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildHomeTab(context),
          const DonorAlertsScreen(),
          const DonorCampsScreen(),
          const DonorProfileScreen(),
        ],
      ),
      bottomNavigationBar: DuoBottomNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: const [
          DuoNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          DuoNavItem(
            icon: Icons.notifications_rounded,
            label: 'Alerts',
          ),
          DuoNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Camps',
          ),
          DuoNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: 'Donor Portal',
        showBackButton: true,
        trailing: [
          // Duolingo Streak Flame Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DuoColors.redTint,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DuoColors.redShadow, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_donationsCount',
                  style: const TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    color: DuoColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Mascot Speech Bubble
            DuoSpeechBubble(
              emoji: '🩸',
              text: 'Welcome back, $_donorName! You are currently ${_isAvailable ? "active and ready to save lives" : "paused"} in Rajahmundry.',
            ),
            const SizedBox(height: 20),

            Text(
              'Hi, $_donorName',
              style: DuoTypography.title1(color: DuoColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Verified BloodNorms Donor ($_donorGroup)',
              style: DuoTypography.subhead(color: DuoColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Status & Availability 3D Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.t('donor.available'),
                            style: DuoTypography.title2(color: DuoColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isAvailable ? 'Ready for emergency alerts' : 'Paused in Supabase',
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAvailable,
                        activeThumbColor: DuoColors.green,
                        onChanged: (val) {
                          if (!val) {
                            _showPauseModal(context);
                          } else {
                            _toggleAvailability(true);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 2, thickness: 2, color: DuoColors.border),
                  const SizedBox(height: 20),

                  // Two Duolingo Candy Rings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          DuoMeter(
                            value: 1.0,
                            color: DuoColors.green,
                            centerText: '✓',
                            subText: loc.t('donor.active'),
                            size: 80,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status',
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const DuoMeter(
                            value: 0.8,
                            color: DuoColors.red,
                            centerText: '14',
                            subText: 'days',
                            size: 80,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.t('donor.next'),
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gamified Impact Badges Row
            Text('Your Impact', style: DuoTypography.title3(color: DuoColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDuoBadge(
                  emoji: '🎖️',
                  title: 'Proven Donor',
                  subtitle: '$_donationsCount Donations',
                  color: DuoColors.red,
                  bgColor: DuoColors.redTint,
                  shadowColor: DuoColors.redShadow,
                ),
                const SizedBox(width: 12),
                _buildDuoBadge(
                  emoji: '⭐',
                  title: 'Reliable',
                  subtitle: '100% answer',
                  color: DuoColors.textPrimary,
                  bgColor: const Color(0xFFF7F7F7),
                  shadowColor: DuoColors.border,
                ),
                const SizedBox(width: 12),
                _buildDuoBadge(
                  emoji: '🎁',
                  title: 'Kit Eligible',
                  subtitle: 'Claimed',
                  color: DuoColors.green,
                  bgColor: DuoColors.greenTint,
                  shadowColor: DuoColors.greenShadow,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active alert banner shortcut in 3D paper card
            GestureDetector(
              onTap: () {
                if (_latestRequestId != null) {
                  context.push('/donor/ticket/$_latestRequestId');
                } else {
                  setState(() => _currentTabIndex = 1);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DuoColors.redTint,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DuoColors.redShadow, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: DuoColors.redShadow,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🎫', style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Donation Pass', style: DuoTypography.headline(color: DuoColors.red)),
                          const SizedBox(height: 2),
                          Text('$_latestRequestHospital · $_latestRequestGroup Whole blood', style: DuoTypography.caption(color: DuoColors.textPrimary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: DuoColors.red, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDuoBadge({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Color shadowColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: shadowColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: DuoTypography.fontFamily,
                color: DuoColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _showPauseModal(BuildContext context) {
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
            Text('Pause Emergency Alerts', style: DuoTypography.title2(color: DuoColors.textPrimary)),
            const SizedBox(height: 8),
            Text('You will not be contacted for emergency requests during this period.', style: DuoTypography.body(color: DuoColors.textSecondary)),
            const SizedBox(height: 20),
            DuoButton(
              label: 'Pause for 7 days',
              variant: DuoButtonVariant.secondary,
              height: 48,
              onPressed: () {
                _toggleAvailability(false);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'Pause for 30 days',
              variant: DuoButtonVariant.secondary,
              height: 48,
              onPressed: () {
                _toggleAvailability(false);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            DuoButton(
              label: 'CANCEL',
              variant: DuoButtonVariant.plain,
              height: 44,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}
