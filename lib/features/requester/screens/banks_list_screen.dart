// ============================================================================
// BloodNorms | banks_list_screen.dart
// Nearest Blood Banks list with Interactive Map — Duolingo Feather Red Style
// Interactive OpenStreetMap with bank markers, 3D paper cards, 3D call buttons
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/progress_meter.dart';
import '../providers/request_flow_provider.dart';

class BanksListScreen extends StatefulWidget {
  const BanksListScreen({super.key});

  @override
  State<BanksListScreen> createState() => _BanksListScreenState();
}

class _BanksListScreenState extends State<BanksListScreen> {
  List<BloodBankModel> _banks = [];
  bool _isLoading = true;
  late final MapController _mapController;
  int? _selectedBankIndex;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final state = globalRequestFlow.state;
    final results = await SupabaseService().getNearestBanks(
      lat: state.lat,
      lng: state.lng,
      bloodGroup: state.bloodGroup?.label,
      component: state.component.code,
    );
    if (mounted) {
      setState(() {
        _banks = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _callBank(String phone) async {
    final clean = phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final userLat = globalRequestFlow.state.lat;
    final userLng = globalRequestFlow.state.lng;
    final userPoint = LatLng(userLat, userLng);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
        title: loc.t('banks.title'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: DuoColors.red),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      children: [
                        // Mascot speech bubble
                        const DuoSpeechBubble(
                          emoji: '🏥',
                          text: 'Check nearest blood banks first! If stock is available, call before you travel.',
                        ),
                        const SizedBox(height: 16),

                        // Interactive Map of Blood Banks (per user request)
                        Container(
                          height: 200,
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
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: userPoint,
                                  initialZoom: 12.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.arkiolabs.bloodnorms',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      // User location marker
                                      Marker(
                                        point: userPoint,
                                        width: 40,
                                        height: 40,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: DuoColors.redTint,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: DuoColors.red, width: 2.5),
                                          ),
                                          child: const Icon(
                                            Icons.my_location_rounded,
                                            size: 20,
                                            color: DuoColors.red,
                                          ),
                                        ),
                                      ),
                                      // Bank markers
                                      ..._banks.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final b = entry.value;
                                        final isSel = _selectedBankIndex == index;

                                        return Marker(
                                          point: LatLng(b.lat, b.lng),
                                          width: 48,
                                          height: 48,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() => _selectedBankIndex = index);
                                              _mapController.move(LatLng(b.lat, b.lng), 14.0);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isSel ? DuoColors.red : Colors.white,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSel ? DuoColors.redShadow : DuoColors.red,
                                                  width: 2.5,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: DuoColors.border,
                                                    offset: Offset(0, 3),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.local_hospital_rounded,
                                                  size: 24,
                                                  color: isSel ? Colors.white : DuoColors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: DuoColors.border, width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.pin_drop_rounded, size: 14, color: DuoColors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_banks.length} Banks nearby',
                                        style: TextStyle(
                                          fontFamily: DuoTypography.fontFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: DuoColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          loc.t('banks.title'),
                          style: DuoTypography.title1(color: DuoColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verified blood banks within 100 km radius',
                          style: DuoTypography.subhead(color: DuoColors.textSecondary),
                        ),
                        const SizedBox(height: 16),

                        // Bank Cards List
                        ..._banks.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final bank = entry.value;
                          return _buildDuoBankCard(context, bank, isHighlighted: _selectedBankIndex == idx);
                        }),
                        const SizedBox(height: 16),

                        // Call before you go warning footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: DuoColors.red),
                            const SizedBox(width: 6),
                            Text(
                              loc.t('banks.call_before'),
                              style: TextStyle(
                                fontFamily: DuoTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: DuoColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
            // Sticky 3D CTA to Search Live Donors
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: DuoButton(
                      label: 'SEARCH VERIFIED DONORS',
                      variant: DuoButtonVariant.primary,
                      onPressed: () => context.push('/units'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuoBankCard(BuildContext context, BloodBankModel bank, {bool isHighlighted = false}) {
    final distanceKm = bank.distanceMeters / 1000.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? DuoColors.red : DuoColors.border,
          width: isHighlighted ? 2.5 : 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: DuoColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Meter
              DuoMeter.stockFreshness(
                units: bank.unitsAvailable,
                freshness: bank.stockFreshness,
                size: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.name,
                      style: DuoTypography.title3(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bank.address,
                      style: DuoTypography.caption(color: DuoColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildDuoPill('${distanceKm.toStringAsFixed(1)} km', DuoColors.textPrimary, const Color(0xFFF0F0F0)),
                        _buildDuoPill('Trust: ${bank.trustScore}', DuoColors.red, DuoColors.redTint),
                        if (bank.isOpen24x7)
                          _buildDuoPill('24x7 OPEN', DuoColors.green, DuoColors.greenTint),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3D Call Bank Button
          DuoButton(
            label: 'CALL BLOOD BANK',
            icon: Icons.phone_rounded,
            height: 44,
            variant: DuoButtonVariant.success,
            onPressed: () => _callBank(bank.phone),
          ),
        ],
      ),
    );
  }

  Widget _buildDuoPill(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: DuoColors.border, width: 1.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: DuoTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
