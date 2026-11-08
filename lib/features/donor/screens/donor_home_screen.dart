// ============================================================================
// BloodNorms | donor_home_screen.dart
// Donor Home Dashboard — Tab Navigator Composing Modular Views
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/app_nav_bar.dart';
import '../widgets/donor_home_tab_view.dart';
import 'donor_alerts_screen.dart';
import 'donor_camps_screen.dart';
import 'donor_profile_screen.dart';

class DonorHomeScreen extends StatefulWidget {
  final int initialTab;
  const DonorHomeScreen({super.key, this.initialTab = 0});

  @override
  State<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  late int _currentTabIndex;
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
    _currentTabIndex = widget.initialTab;
    _loadDonorStats();
  }

  @override
  void didUpdateWidget(covariant DonorHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() => _currentTabIndex = widget.initialTab);
    }
  }

  Future<void> _loadDonorStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dId = prefs.getString('current_donor_id');
      _donorId = dId;

      if (dId == null || dId.isEmpty) {
        if (mounted) {
          context.go('/donor/onboarding');
        }
        return;
      }

      final savedName = prefs.getString('current_donor_name') ?? 'Donor';
      final savedGroup = prefs.getString('current_donor_blood_group') ?? 'O+';
      if (mounted) {
        setState(() {
          _donorName = savedName;
          _donorGroup = savedGroup;
        });
      }

      final donorData = await SupabaseService().getDonor(dId);
      if (donorData != null && mounted) {
        setState(() {
          _donorName =
              donorData['full_name'] ?? donorData['first_name'] ?? savedName;
          _donorGroup = donorData['blood_group'] ?? savedGroup;
          _isAvailable = (donorData['state'] != 'paused');
          _donationsCount =
              (donorData['donations_count'] as num?)?.toInt() ?? 0;
        });
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
      backgroundColor: BrandColors.surfaceSoft,
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
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        items: const [
          AppNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          AppNavItem(
            icon: Icons.notifications_rounded,
            label: 'Alerts',
          ),
          AppNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Camps',
          ),
          AppNavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
