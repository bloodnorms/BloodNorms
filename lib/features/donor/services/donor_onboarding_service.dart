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
  static Future<String?> registerAndPersist({
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

      final finalId = (donorId != null && donorId.isNotEmpty)
          ? donorId
          : 'donor_${DateTime.now().millisecondsSinceEpoch}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_donor_id', finalId);
      await prefs.setString('current_donor_name', fullName.trim());
      await prefs.setString('current_donor_phone', phone.trim());
      await prefs.setString('current_donor_blood_group', bloodGroup.label);

      if (donorId != null && donorId.isNotEmpty) {
        try {
          await SupabaseService().updateDonorLocationPreferences(
            donorId: donorId,
            city: city,
            area: chosenArea,
            travelRadiusKm: travelLimitKm.toDouble(),
            isAway: false,
          );
        } catch (_) {}
      }
      return finalId;
    } catch (e) {
      debugPrint('Error registering donor in service: $e');
      return null;
    }
  }
}
