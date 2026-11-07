// ============================================================================
// BloodNorms | admin_whatsapp_template_service.dart
// WhatsApp Cloud API Pre-Approved Message Template Management
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminWhatsAppTemplateService {
  static final AdminWhatsAppTemplateService _instance =
      AdminWhatsAppTemplateService._internal();
  factory AdminWhatsAppTemplateService() => _instance;
  AdminWhatsAppTemplateService._internal();

  /// WhatsApp Templates & Triggers
  Future<List<Map<String, dynamic>>> getWhatsAppTemplates() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final row = await client
            .from('app_settings')
            .select('value')
            .eq('key', 'whatsapp_templates')
            .maybeSingle();
        final val = row?['value'] as Map<String, dynamic>?;
        if (val != null && val['templates'] is List) {
          return List<Map<String, dynamic>>.from(val['templates']);
        }
      } catch (e) {
        debugPrint('getWhatsAppTemplates error: $e');
      }
    }
    return [
      {
        'id': 'camp_invite',
        'name': 'Blood Camp Invitation',
        'body':
            'Dear {donor_name}, Voluntary Blood Donation Camp is organized at {venue} on {date}. Will you donate? Reply YES to confirm.',
      },
      {
        'id': 'shortage_alert',
        'name': 'Urgent Shortage Alert',
        'body':
            'URGENT: {hospital_name} has critical shortage of {blood_group}. If eligible today, please visit or tap here to accept pass.',
      },
      {
        'id': 'donation_reminder',
        'name': 'Donation Day Reminder',
        'body':
            'Hello {donor_name}, reminder for your scheduled donation today at {bank_name} at {time}. Drink plenty of water!',
      },
      {
        'id': 'appreciation_note',
        'name': 'Donor Thank You',
        'body':
            'Thank you {donor_name}! Your recent donation at {bank_name} saved lives today. You are a true BloodNorms Hero!',
      },
    ];
  }

  Future<bool> saveWhatsAppTemplates(
      List<Map<String, dynamic>> templates) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('app_settings').upsert({
          'key': 'whatsapp_templates',
          'value': {'templates': templates},
          'description':
              'WhatsApp Cloud API pre-approved message templates',
          'updated_at': DateTime.now().toIso8601String(),
        });
        await client.from('audit_logs').insert({
          'action': 'admin_update_whatsapp_templates',
          'target_type': 'app_settings',
          'target_id': 'whatsapp_templates',
          'meta': {'count': templates.length},
        });
        return true;
      } catch (e) {
        debugPrint('saveWhatsAppTemplates error: $e');
      }
    }
    return false;
  }
}
