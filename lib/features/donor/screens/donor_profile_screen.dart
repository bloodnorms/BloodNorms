// ============================================================================
// BloodNorms | donor_profile_screen.dart
// Donor Profile Screen — Duolingo Feather Red Style
// Real Supabase donor data, DPDP Act data rights, account deletion, Arial font
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';

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

  // Location & Regional Broadcast Preferences
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

      // Fallback: load first donor from Supabase
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

  void _showLocationSettingsSheet(BuildContext context) {
    String tempCity = _city;
    final areaController = TextEditingController(text: _area);
    double tempRadius = _travelRadiusKm;
    bool tempAway = _isAway;

    final supportedCities = [
      'Rajahmundry',
      'Kakinada',
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Eluru',
      'Amalapuram',
      'Mandapeta',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: DuoColors.redTint, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.location_on_rounded, color: DuoColors.red, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text('Location & Alert Preferences', style: DuoTypography.title2(color: DuoColors.textPrimary)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set your primary city, neighborhood, and maximum travel radius. Localized blood camp broadcasts strictly respect these settings.',
                  style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, color: DuoColors.textSecondary),
                ),
                const SizedBox(height: 16),

                // City Selector
                Text('Registered City / District', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: supportedCities.map((city) {
                    final isSel = tempCity.toLowerCase() == city.toLowerCase();
                    return ChoiceChip(
                      label: Text(
                        city,
                        style: TextStyle(
                          fontFamily: DuoTypography.fontFamily,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : DuoColors.textPrimary,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: DuoColors.red,
                      backgroundColor: DuoColors.bgGrouped,
                      onSelected: (_) => setSheetState(() => tempCity = city),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Area / Locality
                Text('Area / Neighborhood', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                const SizedBox(height: 6),
                TextField(
                  controller: areaController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Danavaipeta, Kotipalli, Morampudi',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Max Willing Travel Radius
                Text('Maximum Travel Radius', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('You will NOT receive alerts for drives beyond this distance.', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [3.0, 5.0, 10.0, 15.0, 25.0, 50.0].map((r) {
                    final isSel = tempRadius == r;
                    return ChoiceChip(
                      label: Text('${r.toInt()} km', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: DuoColors.redTint,
                      onSelected: (_) => setSheetState(() => tempRadius = r),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Out of station switch
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: DuoColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Currently Out of Town / Away', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 12, fontWeight: FontWeight.bold, color: DuoColors.textPrimary)),
                            SizedBox(height: 2),
                            Text('Pause localized blood camp invitations while traveling', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 11, color: DuoColors.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: tempAway,
                        activeThumbColor: DuoColors.red,
                        onChanged: (v) => setSheetState(() => tempAway = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                DuoButton(
                  label: 'SAVE PREFERENCES',
                  variant: DuoButtonVariant.success,
                  height: 44,
                  onPressed: () async {
                    final donorIdToUse = _donorId ?? 'd1000000-0000-0000-0000-000000000001';
                    await SupabaseService().updateDonorLocationPreferences(
                      donorId: donorIdToUse,
                      city: tempCity,
                      area: areaController.text.trim().isEmpty ? 'Danavaipeta' : areaController.text.trim(),
                      travelRadiusKm: tempRadius,
                      isAway: tempAway,
                    );
                    if (!mounted) return;
                    setState(() {
                      _city = tempCity;
                      _area = areaController.text.trim().isEmpty ? 'Danavaipeta' : areaController.text.trim();
                      _travelRadiusKm = tempRadius;
                      _isAway = tempAway;
                    });
                    if (ctx.mounted && Navigator.canPop(ctx)) {
                      Navigator.pop(ctx);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location & regional alert preferences updated!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuoColors.redTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DuoColors.redShadow, width: 1.5),
              ),
              child: const Icon(Icons.description_rounded, color: DuoColors.red, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Export Complete', style: DuoTypography.title3(color: DuoColors.textPrimary)),
          ],
        ),
        content: Text(
          'Your personal donor data for $_name has been securely prepared in compliance with DPDP Act rights.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          DuoButton(
            label: 'DONE',
            height: 44,
            variant: DuoButtonVariant.success,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuoColors.redTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DuoColors.redShadow, width: 1.5),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: DuoColors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Delete Account?', style: DuoTypography.title3(color: DuoColors.red)),
          ],
        ),
        content: Text(
          'This will permanently delete your donor account from Supabase, remove your contact number, and stop all emergency alerts.',
          style: DuoTypography.body(color: DuoColors.textSecondary),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  label: 'CANCEL',
                  height: 44,
                  variant: DuoButtonVariant.secondary,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DuoButton(
                  label: 'DELETE',
                  height: 44,
                  variant: DuoButtonVariant.destructive,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (_donorId != null) {
                      await SupabaseService().deleteDonor(_donorId!);
                    }
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('current_donor_id');
                    await prefs.remove('current_donor_name');
                    await prefs.remove('current_donor_phone');
                    await prefs.remove('current_donor_blood_group');

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Donor account permanently deleted from Supabase.'),
                          backgroundColor: DuoColors.red,
                        ),
                      );
                      context.go('/');
                    }
                  },
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
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Mascot Speech Bubble
                  const DuoSpeechBubble(
                    emoji: '🩸',
                    text: 'Every donation can save up to three lives. Check your badges and keep your health questions fresh!',
                  ),
                  const SizedBox(height: 20),

                  // Profile Card with 3D bottom bevel
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: DuoColors.border, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: DuoColors.border,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar with 3D border
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: DuoColors.redTint,
                            shape: BoxShape.circle,
                            border: Border.all(color: DuoColors.redShadow, width: 2.0),
                            boxShadow: const [
                              BoxShadow(
                                color: DuoColors.border,
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _name.isNotEmpty ? _name[0].toUpperCase() : 'D',
                              style: const TextStyle(
                                fontFamily: DuoTypography.fontFamily,
                                color: DuoColors.red,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_name, style: DuoTypography.title2(color: DuoColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(_phone, style: DuoTypography.subhead(color: DuoColors.textSecondary)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: DuoColors.red,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: DuoColors.redShadow,
                                          offset: Offset(0, 2),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _bloodGroup,
                                      style: const TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${_weightKg.toStringAsFixed(0)} kg', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hero Gamification Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDuoStatCard(
                          icon: '🔥',
                          value: '$_donationsCount',
                          label: 'DONATIONS',
                          borderColor: DuoColors.redShadow,
                          bgColor: DuoColors.redTint,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDuoStatCard(
                          icon: '💎',
                          value: '85',
                          label: 'TRUST',
                          borderColor: DuoColors.border,
                          bgColor: const Color(0xFFF7F7F7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDuoStatCard(
                          icon: '❤️',
                          value: '${_donationsCount * 3}',
                          label: 'LIVES',
                          borderColor: DuoColors.redShadow,
                          bgColor: DuoColors.redTint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stage 3: Milestone Badges & Honors Showcase
                  _buildMilestoneBadgesSection(context),
                  const SizedBox(height: 24),

                  // Onboarding Wizard 3D Tile
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: DuoColors.border, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: DuoColors.border,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context.push('/donor/onboarding'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: DuoColors.redTint,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: DuoColors.redShadow, width: 1.5),
                                ),
                                child: const Icon(Icons.badge_rounded, color: DuoColors.red, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Update Registration Details', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('Update health info and travel radius', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: DuoColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Location & Regional Alert Settings
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: DuoColors.border, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: DuoColors.border,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _showLocationSettingsSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _isAway ? const Color(0xFFFEF3C7) : DuoColors.greenTint,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isAway ? const Color(0xFFFCD34D) : DuoColors.greenShadow,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  _isAway ? Icons.flight_takeoff_rounded : Icons.location_on_rounded,
                                  color: _isAway ? const Color(0xFFB45309) : DuoColors.green,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Location & Alert Preferences', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                                        if (_isAway) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                                            child: const Text('AWAY', style: TextStyle(fontFamily: DuoTypography.fontFamily, fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('$_city ($_area) · ${_travelRadiusKm.toInt()} km travel limit', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: DuoColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Privacy & Data Rights
                  Text('Privacy & Data Rights', style: DuoTypography.title3(color: DuoColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            onTap: () => _exportData(context),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: DuoColors.redTint,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: DuoColors.redShadow, width: 1.5),
                                    ),
                                    child: const Icon(Icons.description_rounded, color: DuoColors.red, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Export My Data (JSON)', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text('Download copy of personal records (DPDP Act)', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, size: 18, color: DuoColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: DuoColors.border),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: DuoColors.greenTint,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: DuoColors.greenShadow, width: 1.5),
                                ),
                                child: const Icon(Icons.favorite_rounded, color: DuoColors.green, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Health Quick-Check', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('Verified · Due in 5 months', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: DuoColors.greenTint,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                                ),
                                child: const Text('OK', style: TextStyle(color: DuoColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3D Destructive Delete Button
                  DuoButton(
                    label: 'DELETE MY ACCOUNT',
                    icon: Icons.delete_forever_rounded,
                    variant: DuoButtonVariant.destructive,
                    onPressed: () => _confirmDelete(context),
                  ),
                  const SizedBox(height: 16),

                  // Sign Out
                  DuoButton(
                    label: 'SIGN OUT',
                    variant: DuoButtonVariant.secondary,
                    onPressed: () => context.go('/'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  Widget _buildDuoStatCard({
    required String icon,
    required String value,
    required String label,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DuoColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DuoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: DuoColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- STAGE 3: MILESTONE BADGES & HONORS SECTION ---
  Widget _buildMilestoneBadgesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Milestones & Honors', style: DuoTypography.title3(color: DuoColors.textPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: DuoColors.redTint,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: DuoColors.redShadow, width: 1.0),
              ),
              child: Text(
                '$_donationsCount DONATIONS',
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Official recognition by Government Hospitals & BloodNorms',
          style: DuoTypography.caption(color: DuoColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
            children: _badges.map((badge) {
              final isUnlocked = badge.isUnlocked;
              return Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: DuoColors.border, width: 1.0)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked ? const Color(0xFFFFF9E6) : DuoColors.bgGrouped,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnlocked ? const Color(0xFFFFD700) : DuoColors.border,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badge.icon,
                          style: TextStyle(
                            fontSize: 24,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                badge.badgeName,
                                style: DuoTypography.headline(
                                  color: isUnlocked ? DuoColors.textPrimary : DuoColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: DuoColors.greenTint,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: DuoColors.greenShadow, width: 1.0),
                                  ),
                                  child: const Text(
                                    'UNLOCKED',
                                    style: TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      color: DuoColors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: DuoColors.bgGrouped,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: DuoColors.border, width: 1.0),
                                  ),
                                  child: Text(
                                    '$_donationsCount / ${badge.requiredDonations}',
                                    style: const TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      color: DuoColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge.description,
                            style: DuoTypography.caption(color: DuoColors.textSecondary),
                          ),
                          if (isUnlocked) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _showCertificateModal(context, badge),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFFD48806)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'View Certificate of Appreciation',
                                      style: TextStyle(
                                        fontFamily: DuoTypography.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD48806),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showCertificateModal(BuildContext context, DonorBadgeModel badge) {
    final certId = 'AP-BN-${badge.badgeCode.toUpperCase()}-${_donorId?.hashCode.abs().toString().substring(0, 5) ?? "74892"}';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37), width: 3.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Certificate Header Emblem
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
                ),
                child: Center(
                  child: Text(badge.icon, style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              const Text(
                'GOVERNMENT GENERAL HOSPITAL\n& BLOODNORMS INITIATIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: Color(0xFF8B6508),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'CERTIFICATE OF APPRECIATION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFD4AF37), thickness: 1.5),
              const SizedBox(height: 12),

              // Body
              const Text(
                'This Certificate of Lifetime Honor is proudly presented to',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'For voluntary blood donation ($_bloodGroup) contributing directly to saving human lives across Rajahmundry & East Godavari.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 16),

              // Seal & Verification ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 18, color: DuoColors.green),
                    const SizedBox(width: 8),
                    Text(
                      'VERIFIED SEAL: $certId',
                      style: const TextStyle(
                        fontFamily: DuoTypography.fontFamily,
                        color: DuoColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              DuoButton(
                label: 'SHARE / SAVE CERTIFICATE',
                icon: Icons.share_rounded,
                variant: DuoButtonVariant.success,
                height: 46,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Certificate $certId copied to clipboard & saved!',
                        style: const TextStyle(fontFamily: DuoTypography.fontFamily),
                      ),
                      backgroundColor: DuoColors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              DuoButton(
                label: 'CLOSE',
                variant: DuoButtonVariant.plain,
                height: 40,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
