// ============================================================================
// BloodNorms | admin_feature_flags_service.dart
// Progressive Feature Flags and RBAC Permissions Scaffolding
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';

class AdminFeatureFlagsService {
  static final AdminFeatureFlagsService _instance =
      AdminFeatureFlagsService._internal();
  factory AdminFeatureFlagsService() => _instance;
  AdminFeatureFlagsService._internal();

  /// Check if a progressive expansion feature flag is enabled
  Future<bool> isFeatureEnabled(
    String flagKey, {
    bool defaultValue = false,
  }) async {
    // 1. Check local cache first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getBool('flag_$flagKey');
      if (cached != null) return cached;
    } catch (_) {}

    // 2. Query Supabase feature_flags table if online
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('feature_flags')
            .select('enabled')
            .eq('key', flagKey)
            .maybeSingle();
        if (res != null && res['enabled'] != null) {
          final enabled = res['enabled'] == true;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('flag_$flagKey', enabled);
          return enabled;
        }
      } catch (e) {
        debugPrint('Error querying feature flag $flagKey from Supabase: $e');
      }
    }

    return defaultValue;
  }

  /// Get all registered feature flags
  Future<List<Map<String, dynamic>>> getFeatureFlags() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('feature_flags')
            .select()
            .order('category');
        return List<Map<String, dynamic>>.from(res as List);
      } catch (e) {
        debugPrint('Error querying feature_flags: $e');
      }
    }

    // Default flags inventory
    return [
      {
        'key': 'flag_advanced_rbac',
        'name': 'Advanced RBAC & 4-Eyes Approvals',
        'enabled': false,
        'category': 'security'
      },
      {
        'key': 'flag_scoped_maintenance',
        'name': 'Scoped Maintenance Controls',
        'enabled': false,
        'category': 'operations'
      },
      {
        'key': 'flag_data_export_engine',
        'name': 'Multi-Tier Data Export Engine',
        'enabled': false,
        'category': 'data'
      },
      {
        'key': 'flag_cost_computation',
        'name': 'Itemized INR Cost Computation',
        'enabled': false,
        'category': 'finance'
      },
      {
        'key': 'flag_ai_voice_studio',
        'name': 'AI Voice Studio Evaluation',
        'enabled': false,
        'category': 'ai'
      },
      {
        'key': 'flag_data_quality_centre',
        'name': 'Data Quality Anomaly Centre',
        'enabled': false,
        'category': 'data'
      },
      {
        'key': 'flag_global_search_palette',
        'name': 'Global Command Palette (Ctrl+K)',
        'enabled': false,
        'category': 'productivity'
      },
    ];
  }

  /// Update feature flag status
  Future<bool> setFeatureFlag(String flagKey, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('flag_$flagKey', enabled);
    } catch (_) {}

    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    if (isInitialized && client != null) {
      try {
        await client.from('feature_flags').upsert({
          'key': flagKey,
          'enabled': enabled,
          'updated_at': DateTime.now().toIso8601String(),
        });
        return true;
      } catch (e) {
        debugPrint('Error updating feature flag in Supabase: $e');
      }
    }
    return true;
  }

  /// Verify if the current administrator has a specific permission code
  Future<bool> hasAdminPermission(String permissionCode) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.rpc(
          'has_permission',
          params: {'p_permission': permissionCode},
        );
        if (res is bool) return res;
      } catch (e) {
        debugPrint('has_permission RPC error: $e');
      }
    }
    return permissionCode.endsWith('.view');
  }

  /// Get master list of 10 built-in admin roles
  Future<List<Map<String, dynamic>>> getAdminRoles() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res =
            await client.from('admin_roles').select().order('created_at');
        return List<Map<String, dynamic>>.from(res as List);
      } catch (e) {
        debugPrint('Error querying admin_roles: $e');
      }
    }

    return [
      {
        'id': 'super_admin',
        'label': 'Super Admin',
        'description': 'Full system access, promote admins, release kill switch'
      },
      {
        'id': 'admin',
        'label': 'Admin',
        'description': 'Day-to-day operations, settings, content, campaigns'
      },
      {
        'id': 'support',
        'label': 'Support',
        'description': 'Read-limited: look up, resend messages, handle cases'
      },
      {
        'id': 'oncall',
        'label': 'On-Call Responder',
        'description': 'Live requests, Needs-human queue, kill switch'
      },
      {
        'id': 'bank_manager',
        'label': 'Bank Manager',
        'description': 'Banks, stock, partners, bank staff invites'
      },
      {
        'id': 'content_editor',
        'label': 'Content Editor',
        'description': 'Copy deck, help pages, translations'
      },
      {
        'id': 'clinical_reviewer',
        'label': 'Clinical Reviewer',
        'description': 'Approve health questions and eligibility'
      },
      {
        'id': 'legal_officer',
        'label': 'Legal Officer',
        'description': 'Consent texts, policies, data-rights queue'
      },
      {
        'id': 'analyst',
        'label': 'Analyst',
        'description': 'Aggregate dashboards and Tier 1 exports only'
      },
      {
        'id': 'finance',
        'label': 'Finance',
        'description': 'Cost, caps (view), invoices, renewals'
      },
    ];
  }
}
