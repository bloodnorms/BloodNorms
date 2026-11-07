// ============================================================================
// BloodNorms | admin_directory_service.dart
// Healthcare Directory, Community Partners & Requester Profiles
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';
import 'admin_partner_service.dart';
import 'admin_safety_eval_service.dart';

export 'admin_partner_service.dart';
export 'admin_safety_eval_service.dart';

class AdminDirectoryService {
  static final AdminDirectoryService _instance =
      AdminDirectoryService._internal();
  factory AdminDirectoryService() => _instance;
  AdminDirectoryService._internal();

  /// Get verified hospitals with GPS coordinates
  Future<List<Map<String, dynamic>>> getHospitals() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.from('hospitals').select().order('name');
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getHospitals error: $e');
      }
    }
    return [
      {
        'name': 'Government General Hospital (GGH)',
        'city': 'Rajahmundry',
        'district': 'East Godavari',
        'latitude': 17.0005,
        'longitude': 81.8040,
        'is_verified': true,
        'contact_phone': '+918832442222',
        'blood_bank_attached': true
      },
      {
        'name': 'Apollo Speciality Hospitals',
        'city': 'Kakinada',
        'district': 'Kakinada',
        'latitude': 16.9891,
        'longitude': 82.2475,
        'is_verified': true,
        'contact_phone': '+918842345678',
        'blood_bank_attached': true
      },
      {
        'name': 'King George Hospital (KGH)',
        'city': 'Visakhapatnam',
        'district': 'Visakhapatnam',
        'latitude': 17.7042,
        'longitude': 83.3032,
        'is_verified': true,
        'contact_phone': '+918912564891',
        'blood_bank_attached': true
      },
      {
        'name': 'Government General Hospital',
        'city': 'Vijayawada',
        'district': 'NTR',
        'latitude': 16.5062,
        'longitude': 80.6480,
        'is_verified': true,
        'contact_phone': '+918662578912',
        'blood_bank_attached': true
      },
    ];
  }

  /// Get AI voice prompt versions
  Future<List<Map<String, dynamic>>> getAIPromptVersions() =>
      AdminSafetyEvalService().getAIPromptVersions();

  /// Run 60-dialogue synthetic AI evaluation suite
  Future<Map<String, dynamic>> runAIEvaluationSuite({
    required String promptVersionId,
  }) =>
      AdminSafetyEvalService().runAIEvaluationSuite(
        promptVersionId: promptVersionId,
      );

  /// Get safety incidents desk tickets
  Future<List<Map<String, dynamic>>> getSafetyIncidents() =>
      AdminSafetyEvalService().getSafetyIncidents();

  /// Get DPDP compliance requests
  Future<List<Map<String, dynamic>>> getDPDPRequests() =>
      AdminSafetyEvalService().getDPDPRequests();

  /// Get registered community partners
  Future<List<Map<String, dynamic>>> getCommunityPartners() =>
      AdminPartnerService().getCommunityPartners();

  /// Get requester profiles with abuse indicators
  Future<List<Map<String, dynamic>>> getRequesterProfiles() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('requester_profiles')
            .select()
            .order('total_requests', ascending: false);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getRequesterProfiles error: $e');
      }
    }
    return [
      {
        'phone': '+919876543210',
        'full_name': 'K. Satyanarayana',
        'total_requests': 3,
        'cancelled_requests': 0,
        'abuse_score': 0,
        'is_blocked': false
      },
      {
        'phone': '+919440112233',
        'full_name': 'R. Venkatesh',
        'total_requests': 1,
        'cancelled_requests': 0,
        'abuse_score': 0,
        'is_blocked': false
      },
    ];
  }

  /// Set requester block status
  Future<bool> setRequesterBlockStatus({
    required String phone,
    required bool isBlocked,
    String? reason,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('requester_profiles').upsert({
          'phone': phone,
          'is_blocked': isBlocked,
          'blocked_reason': reason,
          'blocked_at': isBlocked ? DateTime.now().toIso8601String() : null,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('setRequesterBlockStatus error: $e');
      }
    }
    return true;
  }
}
