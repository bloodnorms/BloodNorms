// ============================================================================
// BloodNorms | donor_profile_screen.dart
// Donor Profile Screen — Thin Screen Composing Header, Badges & DPDP Controls
// Real Supabase donor data, DPDP Act data rights, account deletion, Arial font
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/speech_bubble.dart';
import '../widgets/donor_dpdp_dialogs.dart';
import '../widgets/donor_privacy_card.dart';
import '../widgets/donor_profile_badges_section.dart';
import '../widgets/donor_profile_header.dart';
import '../widgets/donor_profile_location_sheet.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  String? _donorId;
  String _name = 'Donor';
  String _phone = '+91 98480 12345';
  String _bloodGroup = 'O+';
  double _weightKg = 65.0;
  int _donationsCount = 0;
  List<DonorBadgeModel> _badges = [];
  bool _isLoading = true;

  String _city = 'Rajahmundry';
  String _area = 'Danavaipeta';
  double _travelRadiusKm = 15.0;
  bool _isAway = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
      final savedPhone = prefs.getString('current_donor_phone') ?? _phone;
      final savedGroup = prefs.getString('current_donor_blood_group') ?? 'O+';
      setState(() {
        _name = savedName;
        _phone = savedPhone;
        _bloodGroup = savedGroup;
      });

      final loc = await SupabaseService().getDonorLocationPreferences(dId);
      _city = loc['city']?.toString() ?? 'Rajahmundry';
      _area = loc['area']?.toString() ?? 'Danavaipeta';
      _travelRadiusKm = (loc['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
      _isAway = loc['is_away'] == true;

      final donor = await SupabaseService().getDonor(dId);
      final count = (donor?['donations_count'] as num?)?.toInt() ?? 0;
      final badges = await SupabaseService().getDonorBadges(dId, donationsCount: count);
      if (mounted) {
        setState(() {
          _name = donor?['full_name'] ?? donor?['first_name'] ?? savedName;
          _phone = donor?['phone'] ?? savedPhone;
          _bloodGroup = donor?['blood_group'] ?? savedGroup;
          _weightKg = (donor?['weight_kg'] as num?)?.toDouble() ?? 65.0;
          _donationsCount = count;
          _badges = badges;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_donor_id');
    await prefs.remove('current_donor_name');
    await prefs.remove('current_donor_phone');
    await prefs.remove('current_donor_blood_group');
    if (mounted) context.go('/');
  }

  void _openLocationSettings() {
    showDonorProfileLocationSheet(
      context: context,
      donorId: _donorId ?? '',
      currentCity: _city,
      currentArea: _area,
      currentRadiusKm: _travelRadiusKm,
      currentIsAway: _isAway,
      onSaved: ({required city, required area, required travelRadiusKm, required isAway}) {
        setState(() {
          _city = city;
          _area = area;
          _travelRadiusKm = travelRadiusKm;
          _isAway = isAway;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: const ScreenHeader(title: 'Profile', showBackButton: false),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: BrandColors.primaryAction))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SpeechBubble(
                    emoji: '🩸',
                    text: 'Every donation can save up to three lives. Check your badges and keep your health questions fresh.',
                  ),
                  const SizedBox(height: 20),
                  DonorProfileHeader(
                    name: _name,
                    phone: _phone,
                    bloodGroup: _bloodGroup,
                    weightKg: _weightKg,
                    donationsCount: _donationsCount,
                    city: _city,
                    area: _area,
                    travelRadiusKm: _travelRadiusKm,
                    isAway: _isAway,
                    onOpenLocationSettings: _openLocationSettings,
                  ),
                  const SizedBox(height: 20),
                  DonorProfileBadgesSection(
                    badges: _badges,
                    donationsCount: _donationsCount,
                    donorName: _name,
                    bloodGroup: _bloodGroup,
                    donorId: _donorId,
                  ),
                  const SizedBox(height: 20),
                  DonorPrivacyCard(
                    onExportData: () => showDonorExportDialog(context, _name),
                  ),
                  const SizedBox(height: 20),
                  AppPillButton(
                    label: 'Delete My Account',
                    icon: Icons.delete_outline_rounded,
                    variant: AppPillButtonVariant.destructive,
                    isFullWidth: true,
                    onPressed: () => showDonorConfirmDeleteDialog(context, _donorId),
                  ),
                  const SizedBox(height: 12),
                  AppPillButton(
                    label: 'Sign Out',
                    variant: AppPillButtonVariant.secondary,
                    isFullWidth: true,
                    onPressed: _signOut,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
