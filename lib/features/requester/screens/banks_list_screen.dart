// ============================================================================
// BloodNorms | banks_list_screen.dart
// Nearest Blood Banks list with Interactive Map — Thin Screen Composing Map & Cards
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
import '../providers/request_flow_provider.dart';
import '../widgets/bank_inventory_card.dart';
import '../widgets/banks_map_widget.dart';

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
      backgroundColor: BrandColors.bgGrouped,
      appBar: ScreenHeader(
        title: loc.t('banks.title'),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: BrandColors.red))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      children: [
                        const SpeechBubble(
                          emoji: '🏥',
                          text: 'Check nearest blood banks first! If stock is available, call before you travel.',
                        ),
                        const SizedBox(height: 16),
                        BanksMapWidget(
                          mapController: _mapController,
                          userPoint: userPoint,
                          banks: _banks,
                          selectedBankIndex: _selectedBankIndex,
                          onBankSelected: (index) {
                            setState(() => _selectedBankIndex = index);
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          loc.t('banks.title'),
                          style: BrandTypography.title1(color: BrandColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verified blood banks within 100 km radius',
                          style: BrandTypography.subhead(color: BrandColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ..._banks.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final bank = entry.value;
                          return BankInventoryCard(
                            bank: bank,
                            isHighlighted: _selectedBankIndex == idx,
                            onCall: () => _callBank(bank.phone),
                          );
                        }),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 16, color: BrandColors.red),
                            const SizedBox(width: 6),
                            Text(
                              loc.t('banks.call_before'),
                              style: TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: BrandColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: BrandColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ActionButton(
                  label: 'SEARCH VERIFIED DONORS',
                  variant: ActionButtonVariant.primary,
                  onPressed: () => context.push('/units'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
