// ============================================================================
// BloodNorms | donor_onboarding_screen.dart
// Resumable 8-stage Donor Onboarding Wizard — Duolingo Feather Red Style
// DuoProgressBar, 3D DuoTextFields, Material switches, strict Arial font
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/blood_groups.dart';
import '../../../core/theme/duo_colors.dart';
import '../../../core/theme/duo_typography.dart';
import '../../../core/widgets/duo_blood_tile.dart';
import '../../../core/widgets/duo_button.dart';
import '../../../core/widgets/duo_header_bar.dart';
import '../../../core/widgets/duo_meter.dart';
import '../../../core/widgets/duo_text_field.dart';

class DonorOnboardingScreen extends StatefulWidget {
  const DonorOnboardingScreen({super.key});

  @override
  State<DonorOnboardingScreen> createState() => _DonorOnboardingScreenState();
}

class _DonorOnboardingScreenState extends State<DonorOnboardingScreen> {
  int _step = 0; // 0: Phone, 1: Email, 2: Consents, 3: Bio, 4: Blood, 5: Health, 6: Location, 7: Active

  // Form states
  final _phoneController = TextEditingController(text: '+91 98481 23456');
  final _emailController = TextEditingController(text: 'donor@bloodnorms.org');
  final _nameController = TextEditingController(text: 'Ramesh Varma');
  final _weightController = TextEditingController(text: '68');

  BloodGroup? _bloodGroup = BloodGroup.oPositive;
  bool _plateletsWilling = true;

  // 6 Consents (BR-12, priv, doctor does check)
  final List<bool> _consents = [true, true, true, true, true, true];

  // 10 Health Questions
  int _healthIndex = 0;

  final List<String> _healthQuestions = [
    'Do you have fever, cough or cold today?',
    'Any illness in the last 4 weeks (jaundice, malaria, dengue)?',
    'Are you currently taking any antibiotics?',
    'Have you received any vaccine in the past 4 weeks?',
    'Any surgery or dental extraction in the past 6 months?',
    'Any tattoo, piercing, or acupuncture in the past 6 months?',
    'Are you pregnant or currently breastfeeding?',
    'Have you consumed alcohol in the past 24 hours?',
    'Any chronic heart, kidney, epilepsy or bleeding disorder?',
    'Have you travelled to a high-risk malaria zone recently?',
  ];

  int _travelLimitKm = 10;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 7) {
      setState(() => _step++);
    } else {
      context.go('/donor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bgGrouped,
      appBar: DuoHeaderBar(
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
            // Duolingo Candy Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: DuoProgressBar(
                progress: (_step + 1) / 8,
                fillColor: DuoColors.red,
                height: 16,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildCurrentStep(context),
              ),
            ),
            // Sticky 3D CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: DuoColors.border, width: 2.0)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: DuoButton(
                  label: _step == 7 ? 'GO TO DONOR HOME' : 'CONTINUE',
                  variant: _step == 7 ? DuoButtonVariant.success : DuoButtonVariant.primary,
                  onPressed: _nextStep,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _buildPhoneStep();
      case 1:
        return _buildEmailStep();
      case 2:
        return _buildConsentsStep();
      case 3:
        return _buildBioStep();
      case 4:
        return _buildBloodStep();
      case 5:
        return _buildHealthStep();
      case 6:
        return _buildLocationStep();
      case 7:
      default:
        return _buildSuccessStep();
    }
  }

  // 1. Phone
  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoSpeechBubble(
          emoji: '📱',
          text: 'Welcome! First, enter your mobile number. We verify via WhatsApp OTP—zero spam ever!',
        ),
        const SizedBox(height: 24),
        Text('Mobile Number', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),
        DuoTextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          hintText: '+91 98481 23456',
          prefixIcon: Icons.phone_rounded,
        ),
      ],
    );
  }

  // 2. Email
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoSpeechBubble(
          emoji: '📧',
          text: 'Great! What is your email address? Used for annual eligibility checkups.',
        ),
        const SizedBox(height: 24),
        Text('Email Address', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),
        DuoTextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          hintText: 'name@example.com',
          prefixIcon: Icons.email_rounded,
        ),
      ],
    );
  }

  // 3. Consents
  Widget _buildConsentsStep() {
    final consentLabels = [
      'I agree to be contacted by WhatsApp & automated calls for emergency blood needs.',
      'My phone number will only be shared with the family after I accept a request.',
      'BloodNorms never asks for money or OTP. Blood is always voluntary and free.',
      'The attending doctor at the blood bank does the final medical fitness check.',
      'I am at least 18 years old and weigh 45 kg or more.',
      'I can pause or delete my donor account at any time with complete data removal.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoSpeechBubble(
          emoji: '📜',
          text: 'Please review and confirm these simple donor rules to protect everyone!',
        ),
        const SizedBox(height: 20),
        Text('Your Consents', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),
        ...List.generate(consentLabels.length, (i) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DuoColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: DuoColors.border,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Switch(
                  value: _consents[i],
                  activeThumbColor: DuoColors.red,
                  onChanged: (val) => setState(() => _consents[i] = val),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    consentLabels[i],
                    style: TextStyle(
                      fontFamily: DuoTypography.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: DuoColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 4. Bio (Name, Weight)
  Widget _buildBioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoSpeechBubble(
          emoji: '⚖️',
          text: 'Rule BR-01: Donors must be aged 18–65 and weigh at least 45 kg.',
        ),
        const SizedBox(height: 20),
        Text('Basic Details', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),
        DuoTextField(
          label: 'FULL NAME',
          controller: _nameController,
          hintText: 'Ramesh Varma',
          prefixIcon: Icons.person_rounded,
        ),
        const SizedBox(height: 16),
        DuoTextField(
          label: 'WEIGHT (KG)',
          controller: _weightController,
          keyboardType: TextInputType.number,
          hintText: 'e.g., 68',
          prefixIcon: Icons.fitness_center_rounded,
        ),
      ],
    );
  }

  // 5. Blood Group
  Widget _buildBloodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoSpeechBubble(
          emoji: '🩸',
          text: 'Select your blood group! You can also opt-in for platelet donations.',
        ),
        const SizedBox(height: 20),
        Text('Your Blood Group', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: BloodGroup.values.map((bg) {
            return DuoBloodTile(
              bloodGroup: bg,
              isSelected: _bloodGroup == bg,
              size: 78,
              onTap: () => setState(() => _bloodGroup = bg),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Willing for Platelets?', style: DuoTypography.headline(color: DuoColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Apheresis donation at major centres', style: DuoTypography.caption(color: DuoColors.textSecondary)),
                ],
              ),
              Switch(
                value: _plateletsWilling,
                activeThumbColor: DuoColors.red,
                onChanged: (val) => setState(() => _plateletsWilling = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. Health Check (10 questions, neutral Yes/No)
  Widget _buildHealthStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health Quick-Check', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 6),
        Text(
          'Question ${_healthIndex + 1} of 10 (BR-15)',
          style: TextStyle(
            fontFamily: DuoTypography.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: DuoColors.red,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
              Text(
                _healthQuestions[_healthIndex],
                style: DuoTypography.title2(color: DuoColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: DuoButton(
                      label: 'NO',
                      variant: DuoButtonVariant.secondary,
                      onPressed: () {
                        setState(() {
                          if (_healthIndex < 9) {
                            _healthIndex++;
                          } else {
                            _nextStep();
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DuoButton(
                      label: 'YES',
                      variant: DuoButtonVariant.primary,
                      onPressed: () {
                        setState(() {
                          if (_healthIndex < 9) {
                            _healthIndex++;
                          } else {
                            _nextStep();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Location & Travel Limit
  Widget _buildLocationStep() {
    final travelOptions = [3, 5, 10, 25, 50, 100];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoSpeechBubble(
          emoji: '🚗',
          text: 'How far are you willing to travel for an emergency blood request?',
        ),
        const SizedBox(height: 20),
        Text('Travel Limit', style: DuoTypography.title1(color: DuoColors.textPrimary)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: travelOptions.map((km) {
            final isSel = _travelLimitKm == km;
            return GestureDetector(
              onTap: () => setState(() => _travelLimitKm = km),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? DuoColors.red : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? DuoColors.redShadow : DuoColors.border,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSel ? DuoColors.redShadow : DuoColors.border,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  '$km KM',
                  style: TextStyle(
                    fontFamily: DuoTypography.fontFamily,
                    color: isSel ? Colors.white : DuoColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 8. Success / Active!
  Widget _buildSuccessStep() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: DuoColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DuoColors.greenShadow,
                  offset: Offset(0, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.check_rounded, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'YOU ARE ACTIVE! 🎉',
            style: TextStyle(
              fontFamily: DuoTypography.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DuoColors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your donor profile is verified. You will only be alerted for genuine emergency needs in Rajahmundry matching your group.',
            style: DuoTypography.body(color: DuoColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
