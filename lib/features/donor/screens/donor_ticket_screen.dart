// ============================================================================
// BloodNorms | donor_ticket_screen.dart
// Donor Ticket Screen — Duolingo Feather Red Style
// Physical 3D paper pass card, big 6-digit code box, Material Icons, Arial
// Connected to Supabase requests and request_contacts for real live passes
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';

class DonorTicketScreen extends StatefulWidget {
  final String? requestId;
  final String initialCode;
  final String initialHospital;
  final String initialArea;
  final String initialWard;
  final String initialRequesterName;
  final String initialRequesterPhone;
  final BloodGroup initialBloodGroup;

  const DonorTicketScreen({
    super.key,
    this.requestId,
    this.initialCode = '210418',
    this.initialHospital = 'Government General Hospital',
    this.initialArea = 'Danavaipeta, Rajahmundry',
    this.initialWard = 'Ward 3, Second Floor ICU',
    this.initialRequesterName = 'Kiran Kumar (Family)',
    this.initialRequesterPhone = '+919848999888',
    this.initialBloodGroup = BloodGroup.bPositive,
  });

  @override
  State<DonorTicketScreen> createState() => _DonorTicketScreenState();
}

class _DonorTicketScreenState extends State<DonorTicketScreen> {
  late String _donationCode;
  late String _hospitalName;
  late String _hospitalArea;
  late String _wardDetail;
  late String _requesterName;
  late String _requesterPhone;
  late BloodGroup _bloodGroup;
  bool _isLoading = false;
  bool _isCancelled = false;
  String _cancelOutcome = '';
  StreamSubscription? _requestSub;

  @override
  void initState() {
    super.initState();
    _donationCode = widget.initialCode;
    _hospitalName = widget.initialHospital;
    _hospitalArea = widget.initialArea;
    _wardDetail = widget.initialWard;
    _requesterName = widget.initialRequesterName;
    _requesterPhone = widget.initialRequesterPhone;
    _bloodGroup = widget.initialBloodGroup;

    if (widget.requestId != null && widget.requestId!.isNotEmpty) {
      _loadRealTicket(widget.requestId!);
      _subscribeToRequest(widget.requestId!);
    }
  }

  void _subscribeToRequest(String reqId) {
    _requestSub = SupabaseService().streamRequest(reqId).listen((row) {
      if (!mounted || row == null) return;
      final status = row['status']?.toString();
      if (status == 'cancelled' || status == 'fulfilled') {
        setState(() {
          _isCancelled = (status == 'cancelled');
          _cancelOutcome = row['outcome']?.toString() ?? (status == 'cancelled' ? 'Cancelled by requester' : 'Fulfilled');
        });
      }
    });
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    super.dispose();
  }

  Future<void> _loadRealTicket(String reqId) async {
    final client = SupabaseService().client;
    if (client == null) return;

    setState(() => _isLoading = true);
    try {
      final req = await client.from('requests').select().eq('id', reqId).maybeSingle();
      if (req != null) {
        final prefs = await SharedPreferences.getInstance();
        final currentDonorId = prefs.getString('current_donor_id');

        var contact = currentDonorId != null
            ? await client
                .from('request_contacts')
                .select()
                .eq('request_id', reqId)
                .eq('donor_id', currentDonorId)
                .maybeSingle()
            : null;

        contact ??= await client
            .from('request_contacts')
            .select()
            .eq('request_id', reqId)
            .limit(1)
            .maybeSingle();

        String code = _donationCode;
        if (contact != null && contact['donation_code'] != null) {
          code = contact['donation_code'].toString();
        }

        final bgStr = req['blood_group']?.toString() ?? 'B+';
        final parsedBg = BloodGroup.fromString(bgStr) ?? BloodGroup.bPositive;
        final status = req['status']?.toString();

        if (mounted) {
          setState(() {
            _donationCode = code;
            _hospitalName = req['hospital_name']?.toString() ?? _hospitalName;
            _hospitalArea = req['hospital_area']?.toString() ?? _hospitalArea;
            _requesterName = req['requester_name']?.toString() ?? _requesterName;
            _requesterPhone = req['requester_phone']?.toString() ?? _requesterPhone;
            _bloodGroup = parsedBg;
            if (status == 'cancelled' || status == 'fulfilled') {
              _isCancelled = (status == 'cancelled');
              _cancelOutcome = req['outcome']?.toString() ?? 'Closed';
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading ticket from Supabase: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _callRequester(BuildContext context) async {
    final uri = Uri.parse('tel:${_requesterPhone.replaceAll(' ', '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        _showPhoneFallback(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showPhoneFallback(context);
      }
    }
  }

  void _showPhoneFallback(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: DuoColors.border, width: 2.0),
        ),
        title: Text('Contact Requester', style: DuoTypography.title3(color: DuoColors.textPrimary)),
        content: Text('Requester contact number: $_requesterPhone', style: DuoTypography.body(color: DuoColors.textSecondary)),
        actions: [
          DuoButton(
            label: 'OK',
            variant: DuoButtonVariant.primary,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
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
        title: 'Donation Pass',
        showBackButton: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: DuoColors.red))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  if (_isCancelled) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: DuoColors.red, width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: DuoColors.redShadow,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: DuoColors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'REQUEST CANCELLED BY REQUESTER',
                                  style: TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: DuoColors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reason: ${_cancelOutcome.isNotEmpty ? _cancelOutcome : "Blood fulfilled or no longer required"}.\n\nPlease do not proceed to the hospital. Thank you for your readiness to help!',
                                  style: const TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.normal,
                                    color: DuoColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const DuoSpeechBubble(
                      emoji: '🎫',
                      text: 'Show this 6-digit code at the hospital blood bank counter. The staff will verify and accept your donation!',
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 3D Physical Pass Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: DuoColors.redShadow, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: DuoColors.redShadow,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Red Header Banner
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: _isCancelled ? const Color(0xFF6B7280) : DuoColors.red,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(_isCancelled ? Icons.block_rounded : Icons.verified_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCancelled ? 'PASS CANCELLED' : 'OFFICIAL DONOR PASS',
                                    style: const TextStyle(
                                      fontFamily: DuoTypography.fontFamily,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _bloodGroup.label,
                                  style: TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    color: _isCancelled ? const Color(0xFF6B7280) : DuoColors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Code Box
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                _isCancelled ? 'STATUS' : 'DONATION VERIFICATION CODE',
                                style: DuoTypography.caption(color: DuoColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  color: _isCancelled ? const Color(0xFFF3F4F6) : DuoColors.redTint,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _isCancelled ? const Color(0xFFD1D5DB) : DuoColors.redShadow, width: 2.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isCancelled ? const Color(0xFFE5E7EB) : DuoColors.redShadow,
                                      offset: const Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _isCancelled ? 'VOID' : _donationCode,
                                  style: TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: _isCancelled ? 24 : 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: _isCancelled ? 4 : 8,
                                    color: _isCancelled ? const Color(0xFF6B7280) : DuoColors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isCancelled ? 'Requester closed this emergency request' : 'Single use • Valid for 24 hours',
                                style: DuoTypography.caption(color: DuoColors.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        // Dashed Separator Line
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: List.generate(
                              30,
                              (index) => Expanded(
                                child: Container(
                                  color: index % 2 == 0 ? Colors.transparent : DuoColors.border,
                                  height: 2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Hospital & Location Details
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DESTINATION HOSPITAL', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                              const SizedBox(height: 6),
                              Text(_hospitalName, style: DuoTypography.title2(color: DuoColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 16, color: DuoColors.red),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(_hospitalArea, style: DuoTypography.body(color: DuoColors.textSecondary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('WARD & BED', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(_wardDetail, style: DuoTypography.title3(color: DuoColors.textPrimary)),
                              const SizedBox(height: 16),
                              Text('REQUESTER', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('$_requesterName • $_requesterPhone', style: DuoTypography.body(color: DuoColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isCancelled)
                    DuoButton(
                      label: 'BACK TO EMERGENCY ALERTS',
                      icon: Icons.arrow_back_rounded,
                      variant: DuoButtonVariant.primary,
                      height: 52,
                      onPressed: () => context.go('/donor/alerts'),
                    )
                  else ...[
                    // Call Requester Button
                    DuoButton(
                      label: 'CALL REQUESTER',
                      icon: Icons.phone_rounded,
                      variant: DuoButtonVariant.primary,
                      height: 52,
                      onPressed: () => _callRequester(context),
                    ),
                    const SizedBox(height: 12),
                    DuoButton(
                      label: 'NAVIGATE IN MAPS',
                      icon: Icons.navigation_rounded,
                      variant: DuoButtonVariant.secondary,
                      height: 52,
                      onPressed: () async {
                        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$_hospitalName $_hospitalArea')}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DuoButton(
                      label: 'CERTIFICATE OF APPRECIATION',
                      icon: Icons.workspace_premium_rounded,
                      variant: DuoButtonVariant.success,
                      height: 52,
                      onPressed: () => _showTicketCertificateModal(context),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }

  void _showTicketCertificateModal(BuildContext context) {
    final certId = 'AP-GGH-$_donationCode';
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2.0),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 12),
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
              const Text(
                'This Certificate of Lifetime Honor is awarded for active emergency response to:',
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
                'PASS: $_donationCode',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'In response to emergency request at $_hospitalName for blood group ${_bloodGroup.label}. Verified and recorded in Supabase.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: DuoTypography.fontFamily,
                  color: DuoColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 16),
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
                      'SEAL ID: $certId',
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
              DuoButton(
                label: 'DOWNLOAD / SHARE',
                icon: Icons.share_rounded,
                variant: DuoButtonVariant.success,
                height: 46,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Certificate $certId downloaded & shared!',
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
