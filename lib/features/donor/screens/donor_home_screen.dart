// ============================================================================
// BloodNorms | donor_home_screen.dart
// Donor Home Dashboard — Tab Navigator Composing Modular Views
// ============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/app_nav_bar.dart';
import '../widgets/donor_home_tab_view.dart';
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
            _donorName =
                donorData['full_name'] ?? donorData['first_name'] ?? 'Donor';
            _donorGroup = donorData['blood_group'] ?? 'O+';
            _isAvailable = (donorData['state'] != 'paused');
            _donationsCount =
                (donorData['donations_count'] as num?)?.toInt() ?? 0;
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

      final alerts =
          await SupabaseService().getDonorAlerts(bloodGroup: _donorGroup);
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
      await SupabaseService()
          .updateDonorState(_donorId!, val ? 'active' : 'paused');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          DonorHomeTabView(
            donorName: _donorName,
            donorGroup: _donorGroup,
            isAvailable: _isAvailable,
            donationsCount: _donationsCount,
            latestRequestId: _latestRequestId,
            latestRequestHospital: _latestRequestHospital,
            latestRequestGroup: _latestRequestGroup,
            onToggleAvailability: _toggleAvailability,
            onOpenTab: (index) => setState(() => _currentTabIndex = index),
          ),
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
}
