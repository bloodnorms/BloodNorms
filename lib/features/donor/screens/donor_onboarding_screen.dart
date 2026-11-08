// ============================================================================
// BloodNorms | donor_onboarding_screen.dart
// Resumable 8-stage Donor Onboarding Wizard — Thin Screen Composing Steps
// ProgressMeter, AppTextFields, strict Arial font, DPDP compliant
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/progress_meter.dart';
import '../../../shared/widgets/screen_header.dart';
import '../services/donor_onboarding_service.dart';
import '../widgets/onboarding_bio_blood_step.dart';
import '../widgets/onboarding_consents_step.dart';
import '../widgets/onboarding_contact_steps.dart';
import '../widgets/onboarding_health_step.dart';
import '../widgets/onboarding_location_step.dart';
import '../widgets/onboarding_success_step.dart';

class DonorOnboardingScreen extends StatefulWidget {
  const DonorOnboardingScreen({super.key});

  @override
  State<DonorOnboardingScreen> createState() => _DonorOnboardingScreenState();
}

class _DonorOnboardingScreenState extends State<DonorOnboardingScreen> {
  int _step = 0;

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _areaController = TextEditingController(text: 'Danavaipeta');

  BloodGroup? _bloodGroup = BloodGroup.oPositive;
  bool _plateletsWilling = true;
  final List<bool> _consents = [true, true, true, true, true, true];
  int _healthIndex = 0;
  int _travelLimitKm = 10;
  String _selectedCity = 'Rajahmundry';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: BrandColors.statusError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _nextStep() async {
    if (_step == 0) {
      final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9+]'), '');
      if (phone.length < 10) return _showError('Please enter a valid 10-digit mobile number.');
    } else if (_step == 2) {
      if (_consents.any((c) => !c)) return _showError('Please accept all donor terms to continue.');
    } else if (_step == 3) {
      if (_nameController.text.trim().isEmpty) return _showError('Please enter your full name.');
      final w = double.tryParse(_weightController.text.trim());
      if (w == null || w < 45) return _showError('Donors must weigh at least 45 kg per medical guidelines.');
    } else if (_step == 4) {
      if (_bloodGroup == null) return _showError('Please select your blood group.');
    }

    if (_step < 7) {
      if (_step == 6) {
        setState(() => _isSubmitting = true);
        await DonorOnboardingService.registerAndPersist(
          fullName: _nameController.text,
          phone: _phoneController.text,
          bloodGroup: _bloodGroup ?? BloodGroup.oPositive,
          weightKg: double.tryParse(_weightController.text.trim()) ?? 65.0,
          city: _selectedCity,
          area: _areaController.text,
          travelLimitKm: _travelLimitKm,
        );
        if (mounted) setState(() => _isSubmitting = false);
      }
      if (mounted) setState(() => _step++);
    } else {
      context.go('/donor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: ScreenHeader(
        title: 'Donor Registration',
        showBackButton: _step > 0,
        onBackOverride: () {
          if (_step > 0) {
            setState(() => _step--);
          } else {
            context.pop();
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: StepProgressBar(
                progress: (_step + 1) / 8,
                fillColor: BrandColors.primaryAction,
                height: 6,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildCurrentStep(),
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
                  label: _isSubmitting ? 'Saving...' : (_step == 7 ? 'Go to Donor Home' : 'Continue'),
                  variant: AppPillButtonVariant.primary,
                  isFullWidth: true,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _nextStep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return OnboardingPhoneStep(controller: _phoneController);
      case 1:
        return OnboardingEmailStep(controller: _emailController);
      case 2:
        return OnboardingConsentsStep(consents: _consents, onConsentChanged: (i, v) => setState(() => _consents[i] = v));
      case 3:
        return OnboardingBioStep(nameController: _nameController, weightController: _weightController);
      case 4:
        return OnboardingBloodStep(
          bloodGroup: _bloodGroup,
          plateletsWilling: _plateletsWilling,
          onBloodGroupSelected: (bg) => setState(() => _bloodGroup = bg),
          onPlateletsChanged: (v) => setState(() => _plateletsWilling = v),
        );
      case 5:
        return OnboardingHealthStep(
          healthIndex: _healthIndex,
          onAnswer: () => setState(() {
            if (_healthIndex < 9) {
              _healthIndex++;
            } else {
              _nextStep();
            }
          }),
        );
      case 6:
        return OnboardingLocationStep(
          selectedCity: _selectedCity,
          areaController: _areaController,
          travelLimitKm: _travelLimitKm,
          onCityChanged: (c) => setState(() => _selectedCity = c),
          onTravelLimitChanged: (km) => setState(() => _travelLimitKm = km),
        );
      case 7:
      default:
        return const OnboardingSuccessStep();
    }
  }
}
