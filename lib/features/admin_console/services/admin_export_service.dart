// ============================================================================
// BloodNorms | admin_export_service.dart
// Multi-Tier Data Export Engine with CSV Injection Sanitization & Watermarking
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/supabase_service.dart';

class AdminExportService {
  static final AdminExportService _instance = AdminExportService._internal();
  factory AdminExportService() => _instance;
  AdminExportService._internal();

  /// Sanitize cell content to prevent CSV injection (=, +, -, @)
  String sanitizeCsvCell(String input) {
    if (input.isEmpty) return input;
    final firstChar = input[0];
    if (firstChar == '=' ||
        firstChar == '+' ||
        firstChar == '-' ||
        firstChar == '@') {
      return "'$input";
    }
    return input;
  }

  /// Create a new data export (enforces Four-Eyes approval check for Tier 3)
  Future<Map<String, dynamic>> createDataExport({
    required String entityType,
    required String tier,
    required String format,
    required String reason,
    int rowCount = 0,
    Map<String, dynamic>? filterParams,
    String? approvalId,
  }) async {
    if (tier == 'tier_3_identifiers' && approvalId == null) {
      return {
        'ok': false,
        'reason':
            'Tier 3 (Identifiable data) mandates Four-Eyes approval before generation.',
      };
    }

    final watermark =
        'BN-EXP-${DateTime.now().millisecondsSinceEpoch}-${entityType.toUpperCase()}';
    final exportEntry = {
      'id': 'exp-${DateTime.now().millisecondsSinceEpoch}',
      'entity_type': entityType,
      'tier': tier,
      'format': format,
      'status': 'completed',
      'row_count': rowCount,
      'filter_params': filterParams ?? {},
      'watermark_token': watermark,
      'approval_id': approvalId,
      'reason': reason,
      'expires_at':
          DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('create_data_export', params: {
          'p_entity_type': entityType,
          'p_tier': tier,
          'p_format': format,
          'p_reason': reason,
          'p_row_count': rowCount,
          'p_filter': filterParams ?? {},
          'p_approval_id': approvalId,
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('createDataExport error: $e');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('local_exports_cache');
      List list = cached != null ? jsonDecode(cached) as List : [];
      list.insert(0, exportEntry);
      await prefs
          .setString('local_exports_cache', jsonEncode(list.take(20).toList()));
    } catch (_) {}

    return {
      'ok': true,
      'export_id': exportEntry['id'],
      'watermark': watermark,
      'expires_at': exportEntry['expires_at'],
    };
  }

  /// Get recent data exports history
  Future<List<Map<String, dynamic>>> getDataExports() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('data_exports')
            .select()
            .order('created_at', ascending: false)
            .limit(20);
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getDataExports error: $e');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('local_exports_cache');
      if (cached != null) {
        final List list = jsonDecode(cached) as List;
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}

    return [
      {
        'id': 'exp-mock-01',
        'entity_type': 'requests',
        'tier': 'tier_2_masked',
        'format': 'csv',
        'status': 'completed',
        'row_count': 42,
        'watermark_token': 'BN-EXP-20261107-123456',
        'reason': 'Weekly Operations Audit',
        'expires_at':
            DateTime.now().add(const Duration(minutes: 12)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }
    ];
  }
}
