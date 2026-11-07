// ============================================================================
// BloodNorms | request_details_screen.dart
// Requester Details Screen — Duolingo Feather Red Style
// Functional 3D DuoTextField inputs, Material switch, privacy bubble
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/request_flow_provider.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late final TextEditingController _hospitalController;
  late final TextEditingController _patientController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;
  bool _allowCompatible = false;

  @override
  void initState() {
    super.initState();
    final state = globalRequestFlow.state;
    _hospitalController = TextEditingController(
      text: state.hospitalName.isNotEmpty
          ? state.hospitalName
          : (state.placeLabel != 'Rajahmundry, Andhra Pradesh' ? state.placeLabel : ''),
    );
    _patientController = TextEditingController(text: state.patientFirstName);
    _phoneController = TextEditingController(text: state.requesterPhone);
    _noteController = TextEditingController(text: state.note);
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
            fontFamily: DuoTypography.fontFamily,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: DuoColors.red,
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: const DuoHeaderBar(
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
                    // Duolingo Speech Bubble
                    const DuoSpeechBubble(
                      emoji: '🔒',
                      text: 'Your contact details stay safe! They are only revealed to donors who accept your request.',
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Patient & Hospital',
                      style: DuoTypography.title1(color: DuoColors.textPrimary),
                    ),
                    const SizedBox(height: 20),

                    // Hospital Name
                    DuoTextField(
                      label: 'HOSPITAL NAME',
                      controller: _hospitalController,
                      hintText: 'e.g., GGH Rajahmundry',
                      prefixIcon: Icons.local_hospital_rounded,
                    ),
                    const SizedBox(height: 8),

                    // Quick Hospital selection chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'GGH Rajahmundry',
                          'Red Cross Society Blood Centre',
                          'Swatantra Blood Bank',
                          'Bollineni Hospital',
                          'Suraksha Rotary Centre',
                        ].map((hosp) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () => setState(() => _hospitalController.text = hosp),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: DuoColors.border, width: 1.0),
                                ),
                                child: Text(
                                  hosp,
                                  style: const TextStyle(
                                    fontFamily: DuoTypography.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: DuoColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Patient First Name
                    DuoTextField(
                      label: 'PATIENT FIRST NAME',
                      controller: _patientController,
                      hintText: 'e.g., Suresh',
                      prefixIcon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 20),

                    // Requester Phone (+91)
                    DuoTextField(
                      label: 'YOUR MOBILE NUMBER',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      hintText: '+91 98480 12345',
                      prefixIcon: Icons.phone_rounded,
                    ),
                    const SizedBox(height: 24),

                    // Compatible groups 3D card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: DuoColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: DuoColors.border,
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Universal Compatible Donors',
                                  style: DuoTypography.headline(color: DuoColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Allow universal compatible donors (BR-04)',
                                  style: DuoTypography.caption(color: DuoColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _allowCompatible,
                            activeThumbColor: DuoColors.red,
                            onChanged: (val) => setState(() => _allowCompatible = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Note to donors
                    DuoTextField(
                      label: 'NOTE TO DONORS (OPTIONAL)',
                      controller: _noteController,
                      maxLines: 3,
                      hintText: 'e.g., Surgery scheduled tomorrow at 9 AM',
                      prefixIcon: Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Sticky 3D Continue
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DuoButton(
                  label: loc.t('cta.continue'),
                  variant: DuoButtonVariant.primary,
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
