// ============================================================================
// BloodNorms | donor_onboarding_service.dart
// Registration and location persistence service for donor onboarding flow
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/services/supabase_service.dart';

class DonorOnboardingService {
  static Future<void> registerAndPersist({
    required String fullName,
    required String phone,
    required BloodGroup bloodGroup,
    required double weightKg,
    required String city,
    required String area,
    required int travelLimitKm,
  }) async {
    final chosenArea = area.trim().isEmpty ? 'Danavaipeta' : area.trim();
    try {
      final donorId = await SupabaseService().registerDonor(
        fullName: fullName.trim(),
        phone: phone.trim(),
        bloodGroup: bloodGroup.label,
        gender: 'male',
        dob: DateTime.now().subtract(const Duration(days: 365 * 25)),
        weightKg: weightKg,
        lat: AppConstants.defaultLat,
        lng: AppConstants.defaultLng,
        area: chosenArea,
        city: city,
      );

      if (donorId != null && donorId.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_donor_id', donorId);
        await prefs.setString('current_donor_name', fullName.trim());
        await prefs.setString('current_donor_phone', phone.trim());
        await prefs.setString('current_donor_blood_group', bloodGroup.label);

        await SupabaseService().updateDonorLocationPreferences(
          donorId: donorId,
          city: city,
          area: chosenArea,
          travelRadiusKm: travelLimitKm.toDouble(),
          isAway: false,
        );
      }
    } catch (e) {
      debugPrint('Error registering donor in service: $e');
    }
  }
}
