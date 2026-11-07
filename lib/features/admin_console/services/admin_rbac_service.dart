// ============================================================================
// BloodNorms | admin_rbac_service.dart
// Role-Based Access Control (RBAC) Permissions & Built-in Admin Roles
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminRbacService {
  static final AdminRbacService _instance = AdminRbacService._internal();
  factory AdminRbacService() => _instance;
  AdminRbacService._internal();

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
