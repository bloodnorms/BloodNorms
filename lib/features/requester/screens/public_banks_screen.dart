// ============================================================================
// BloodNorms | public_banks_screen.dart
// Public Blood Banks Directory (/b) with Map — Thin Screen Composing Map & Cards
// Interactive OpenStreetMap, honest stock rings, verified hospital directory
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../widgets/bank_inventory_card.dart';
import '../widgets/public_banks_map_widget.dart';

class PublicBanksScreen extends StatefulWidget {
  const PublicBanksScreen({super.key});

  @override
  State<PublicBanksScreen> createState() => _PublicBanksScreenState();
}

class _PublicBanksScreenState extends State<PublicBanksScreen> {
  List<BloodBankModel> _banks = [];
  bool _isLoading = true;
  late final MapController _mapController;
  int? _selectedBankIndex;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    final results = await SupabaseService().getNearestBanks(
      lat: AppConstants.defaultLat,
      lng: AppConstants.defaultLng,
    );
    if (mounted) {
      setState(() {
        _banks = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _callBank(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/918832471234?text=Hi');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cityPoint = LatLng(AppConstants.defaultLat, AppConstants.defaultLng);

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
                          emoji: '🏦',
                          text: 'Browse honest stock from verified blood banks in Rajahmundry! Call before you go.',
                        ),
                        const SizedBox(height: 16),
                        PublicBanksMapWidget(
                          mapController: _mapController,
                          cityPoint: cityPoint,
                          banks: _banks,
                          selectedBankIndex: _selectedBankIndex,
                          onBankSelected: (idx) => setState(() => _selectedBankIndex = idx),
                        ),
                        const SizedBox(height: 20),
                        Text(loc.t('banks.title'), style: BrandTypography.title1(color: BrandColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Verified blood banks in ${AppConstants.pilotCity}', style: BrandTypography.subhead(color: BrandColors.textSecondary)),
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
              child: Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      label: 'NEED BLOOD',
                      icon: Icons.water_drop_rounded,
                      variant: ActionButtonVariant.primary,
                      onPressed: () => context.push('/group'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionButton(
                      label: 'WHATSAPP',
                      icon: Icons.chat_rounded,
                      variant: ActionButtonVariant.success,
                      onPressed: _launchWhatsApp,
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
}
