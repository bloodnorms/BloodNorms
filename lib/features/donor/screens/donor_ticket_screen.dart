// ============================================================================
// BloodNorms | donor_ticket_screen.dart
// Donor Ticket Screen — Thin Screen Composing DonorPassCard & DonorTicketActions
// Connected to Supabase requests and request_contacts for real live passes
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/speech_bubble.dart';
import '../widgets/donor_cancelled_banner.dart';
import '../widgets/donor_pass_card.dart';
import '../widgets/donor_ticket_actions.dart';

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
            ? await client.from('request_contacts').select().eq('request_id', reqId).eq('donor_id', currentDonorId).maybeSingle()
            : null;

        contact ??= await client.from('request_contacts').select().eq('request_id', reqId).limit(1).maybeSingle();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: const ScreenHeader(
        title: 'Donation Pass',
        showBackButton: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: BrandColors.primaryAction))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  if (_isCancelled)
                    DonorCancelledBanner(outcomeReason: _cancelOutcome)
                  else ...[
                    const SpeechBubble(
                      emoji: '🎫',
                      text: 'Show this 6-digit code at the hospital blood bank counter. The staff will verify and accept your donation.',
                    ),
                    const SizedBox(height: 20),
                  ],
                  DonorPassCard(
                    donationCode: _donationCode,
                    hospitalName: _hospitalName,
                    hospitalArea: _hospitalArea,
                    wardDetail: _wardDetail,
                    requesterName: _requesterName,
                    requesterPhone: _requesterPhone,
                    bloodGroup: _bloodGroup,
                    isCancelled: _isCancelled,
                  ),
                  const SizedBox(height: 20),
                  DonorTicketActions(
                    isCancelled: _isCancelled,
                    hospitalName: _hospitalName,
                    hospitalArea: _hospitalArea,
                    requesterPhone: _requesterPhone,
                    donationCode: _donationCode,
                    bloodGroup: _bloodGroup,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
