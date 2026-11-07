// ============================================================================
// BloodNorms | request_details_screen.dart
// Requester Details Screen — Duolingo Feather Red Style
// Functional 3D DuoTextField inputs, Material switch, privacy bubble
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_text_field.dart';
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
      text: state.hospitalName.isNotEmpty ? state.hospitalName : 'GGH Rajahmundry',
    );
    _patientController = TextEditingController(
      text: state.patientFirstName.isNotEmpty ? state.patientFirstName : 'Rao',
    );
    _phoneController = TextEditingController(
      text: state.requesterPhone.isNotEmpty ? state.requesterPhone : '+91 98480 12345',
    );
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

  void _onContinue() {
    final hosp = _hospitalController.text.trim().isNotEmpty
        ? _hospitalController.text.trim()
        : 'Hospital in ${AppConstants.pilotCity}';
    final patient = _patientController.text.trim().isNotEmpty
        ? _patientController.text.trim()
        : 'Family Member';
    final phone = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : '+919848012345';

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
