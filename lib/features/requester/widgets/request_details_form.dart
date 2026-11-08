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
          prefixIcon: Icons.local_hospital_outlined,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickHospitals.map((hosp) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  onTap: () => onSelectHospitalChip(hosp),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: BrandColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                    ),
                    child: Text(
                      hosp,
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: 'YOUR MOBILE NUMBER',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          hintText: '+91 98480 12345',
          prefixIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Allow Compatible Blood Groups',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
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
                activeThumbColor: BrandColors.primaryAction,
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
