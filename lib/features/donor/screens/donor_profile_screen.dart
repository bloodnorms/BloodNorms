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
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
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

      if (dId != null && dId.isNotEmpty) {
        final loc = await SupabaseService().getDonorLocationPreferences(dId);
        _city = loc['city']?.toString() ?? 'Rajahmundry';
        _area = loc['area']?.toString() ?? 'Danavaipeta';
        _travelRadiusKm = (loc['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
        _isAway = loc['is_away'] == true;

        final donor = await SupabaseService().getDonor(dId);
        if (donor != null && mounted) {
          final count = (donor['donations_count'] as num?)?.toInt() ?? 0;
          final badges = await SupabaseService().getDonorBadges(dId, donationsCount: count);
          setState(() {
            _name = donor['full_name'] ?? donor['first_name'] ?? 'Donor';
            _phone = donor['phone'] ?? _phone;
            _bloodGroup = donor['blood_group'] ?? 'O+';
            _weightKg = (donor['weight_kg'] as num?)?.toDouble() ?? 65.0;
            _donationsCount = count;
            _badges = badges;
            _isLoading = false;
          });
          return;
        }
      }

      final allDonors = await SupabaseService().getAllDonors();
      if (allDonors.isNotEmpty && mounted) {
        final d = allDonors.first;
        _donorId = d['id']?.toString();
        final loc = await SupabaseService().getDonorLocationPreferences(_donorId ?? 'current-donor');
        _city = loc['city']?.toString() ?? 'Rajahmundry';
        _area = loc['area']?.toString() ?? 'Danavaipeta';
        _travelRadiusKm = (loc['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
        _isAway = loc['is_away'] == true;

        final count = (d['donations_count'] as num?)?.toInt() ?? 0;
        final badges = await SupabaseService().getDonorBadges(_donorId ?? 'current-donor', donationsCount: count);
        setState(() {
          _name = d['full_name'] ?? d['first_name'] ?? 'Donor';
          _phone = d['phone'] ?? _phone;
          _bloodGroup = d['blood_group'] ?? 'O+';
          _weightKg = (d['weight_kg'] as num?)?.toDouble() ?? 65.0;
          _donationsCount = count;
          _badges = badges;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }

    if (mounted) {
      final badges = await SupabaseService().getDonorBadges('default-donor', donationsCount: _donationsCount);
      setState(() {
        _badges = badges;
        _isLoading = false;
      });
    }
  }

  void _openLocationSettings() {
    showDonorProfileLocationSheet(
      context: context,
      donorId: _donorId ?? 'd1000000-0000-0000-0000-000000000001',
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
      backgroundColor: BrandColors.bgGrouped,
      appBar: const ScreenHeader(title: 'Profile', showBackButton: false),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: BrandColors.red))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SpeechBubble(
                    emoji: '🩸',
                    text: 'Every donation can save up to three lives. Check your badges and keep your health questions fresh!',
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
                  const SizedBox(height: 24),
                  DonorProfileBadgesSection(
                    badges: _badges,
                    donationsCount: _donationsCount,
                    donorName: _name,
                    bloodGroup: _bloodGroup,
                    donorId: _donorId,
                  ),
                  const SizedBox(height: 24),
                  DonorPrivacyCard(
                    onExportData: () => showDonorExportDialog(context, _name),
                  ),
                  const SizedBox(height: 24),
                  ActionButton(
                    label: 'DELETE MY ACCOUNT',
                    icon: Icons.delete_forever_rounded,
                    variant: ActionButtonVariant.destructive,
                    onPressed: () => showDonorConfirmDeleteDialog(context, _donorId),
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    label: 'SIGN OUT',
                    variant: ActionButtonVariant.secondary,
                    onPressed: () => context.go('/'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
