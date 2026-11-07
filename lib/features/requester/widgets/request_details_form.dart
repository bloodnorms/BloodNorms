// ============================================================================
// BloodNorms | request_details_form.dart
// Form inputs for hospital, patient name, contact number, and note
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_text_field.dart';

class RequestDetailsForm extends StatelessWidget {
  final TextEditingController hospitalController;
  final TextEditingController patientController;
  final TextEditingController phoneController;
  final TextEditingController noteController;
  final bool allowCompatible;
  final ValueChanged<bool> onToggleCompatible;
  final ValueChanged<String> onSelectHospitalChip;

  const RequestDetailsForm({
    super.key,
    required this.hospitalController,
    required this.patientController,
    required this.phoneController,
    required this.noteController,
    required this.allowCompatible,
    required this.onToggleCompatible,
    required this.onSelectHospitalChip,
  });

  static const List<String> quickHospitals = [
    'GGH Rajahmundry',
    'Red Cross Society Blood Centre',
    'Swatantra Blood Bank',
    'Bollineni Hospital',
    'Suraksha Rotary Centre',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'HOSPITAL NAME',
          controller: hospitalController,
          hintText: 'e.g., GGH Rajahmundry',
          prefixIcon: Icons.local_hospital_rounded,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickHospitals.map((hosp) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onSelectHospitalChip(hosp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: BrandColors.border, width: 1.0),
                    ),
                    child: Text(
                      hosp,
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'PATIENT FIRST NAME',
          controller: patientController,
          hintText: 'e.g., Suresh',
          prefixIcon: Icons.person_rounded,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'YOUR MOBILE NUMBER',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          hintText: '+91 98480 12345',
          prefixIcon: Icons.phone_rounded,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BrandColors.border, width: 2.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allow Compatible Blood Groups',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Includes universal donor groups (e.g., O- for anyone)',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: allowCompatible,
                activeColor: BrandColors.red,
                onChanged: onToggleCompatible,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'OPTIONAL NOTE FOR DONORS',
          controller: noteController,
          hintText: 'e.g., Surgery scheduled for tomorrow 9 AM',
          maxLines: 2,
        ),
      ],
    );
  }
}

