// ============================================================================
// BloodNorms | request_details_screen.dart
// Patient details form screen — Thin Screen Composing Form & Validation
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/speech_bubble.dart';
import '../providers/request_flow_provider.dart';
import '../widgets/request_details_form.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  final _hospitalController = TextEditingController();
  final _patientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  bool _allowCompatible = true;

  @override
  void initState() {
    super.initState();
    final state = globalRequestFlow.state;
    _hospitalController.text = state.hospitalName.isNotEmpty
        ? state.hospitalName
        : (state.placeLabel.isNotEmpty && state.placeLabel != 'Rajahmundry, Andhra Pradesh'
            ? state.placeLabel.split(',').first.trim()
            : '');
    _patientController.text = state.patientFirstName;
    _phoneController.text = state.requesterPhone;
    _noteController.text = state.note;
    _allowCompatible = state.allowCompatible;
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _patientController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: BrandTypography.fontFamily,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: BrandColors.statusError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onContinue() {
    final hosp = _hospitalController.text.trim();
    final patient = _patientController.text.trim();
    final phone = _phoneController.text.trim();

    if (hosp.isEmpty) {
      _showError('Please enter the hospital name.');
      return;
    }
    if (patient.isEmpty) {
      _showError('Please enter the patient\'s name.');
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.length < 10) {
      _showError('Please enter a valid 10-digit mobile number.');
      return;
    }

    globalRequestFlow.setHospitalDetails(name: hosp, area: AppConstants.pilotCity);
    globalRequestFlow.setPatientDetails(firstName: patient);
    globalRequestFlow.setRequesterPhone(phone);
    globalRequestFlow.setAllowCompatible(_allowCompatible);
    globalRequestFlow.setNote(_noteController.text.trim());

    context.push('/review');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: const ScreenHeader(
        title: 'Request Details',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SpeechBubble(
                      emoji: '🔒',
                      text: 'Your contact details stay safe. They are only revealed to donors who accept your request.',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Patient & Hospital',
                      style: BrandTypography.title2(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    RequestDetailsForm(
                      hospitalController: _hospitalController,
                      patientController: _patientController,
                      phoneController: _phoneController,
                      noteController: _noteController,
                      allowCompatible: _allowCompatible,
                      onToggleCompatible: (val) => setState(() => _allowCompatible = val),
                      onSelectHospitalChip: (hosp) => setState(() => _hospitalController.text = hosp),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: BrandColors.background,
                border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
              ),
              child: SafeArea(
                top: false,
                child: AppPillButton(
                  label: 'Continue to Review',
                  variant: AppPillButtonVariant.primary,
                  isFullWidth: true,
                  onPressed: _onContinue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
