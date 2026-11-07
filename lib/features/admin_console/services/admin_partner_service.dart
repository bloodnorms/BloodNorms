// ============================================================================
// BloodNorms | admin_partner_service.dart
// Registered Community Partners Directory (Red Cross, Rotary, Lions, NSS)
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminPartnerService {
  static final AdminPartnerService _instance =
      AdminPartnerService._internal();
  factory AdminPartnerService() => _instance;
  AdminPartnerService._internal();

  /// Get registered community partners
  Future<List<Map<String, dynamic>>> getCommunityPartners() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.from('partners').select().order('name');
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getCommunityPartners error: $e');
      }
    }
    return [
      {
        'name': 'Indian Red Cross Society (East Godavari)',
        'organization_type': 'red_cross',
        'contact_person': 'District Coordinator',
        'camps_organized_count': 12,
        'is_active': true
      },
      {
        'name': 'Rotary Club of Rajahmundry',
        'organization_type': 'rotary',
        'contact_person': 'Camp Director',
        'camps_organized_count': 8,
        'is_active': true
      },
      {
        'name': 'Lions Club International Godavari',
        'organization_type': 'lions',
        'contact_person': 'President',
        'camps_organized_count': 5,
        'is_active': true
      },
      {
        'name': 'National Service Scheme (NSS) AU',
        'organization_type': 'nss',
        'contact_person': 'Program Officer',
        'camps_organized_count': 9,
        'is_active': true
      },
    ];
  }
}
