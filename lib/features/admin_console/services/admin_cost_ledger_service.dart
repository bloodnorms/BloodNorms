// ============================================================================
// BloodNorms | admin_cost_ledger_service.dart
// Telecom, LLM & Meta Cloud API Cost Ledgers, Itemized Rates & Spend Summary
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminCostLedgerService {
  static final AdminCostLedgerService _instance =
      AdminCostLedgerService._internal();
  factory AdminCostLedgerService() => _instance;
  AdminCostLedgerService._internal();

  /// Get current service cost rate cards in INR
  Future<List<Map<String, dynamic>>> getCostRateCards() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client
            .from('cost_rate_cards')
            .select()
            .order('service_name');
        return List<Map<String, dynamic>>.from(res);
      } catch (e) {
        debugPrint('getCostRateCards error: $e');
      }
    }

    return [
      {
        'service_name': 'whatsapp_utility',
        'unit_cost_inr': 0.3500,
        'unit_label': 'per template'
      },
      {
        'service_name': 'whatsapp_marketing',
        'unit_cost_inr': 0.8500,
        'unit_label': 'per template'
      },
      {
        'service_name': 'twilio_voice_min',
        'unit_cost_inr': 1.8000,
        'unit_label': 'per minute'
      },
      {
        'service_name': 'gemini_live_min',
        'unit_cost_inr': 2.4000,
        'unit_label': 'per minute'
      },
      {
        'service_name': 'sms_failover',
        'unit_cost_inr': 0.2800,
        'unit_label': 'per SMS'
      },
    ];
  }

  /// Record cost event attributed to an emergency request
  Future<Map<String, dynamic>> recordCostEvent({
    required String requestId,
    required String serviceName,
    double units = 1.0,
    Map<String, dynamic>? meta,
  }) async {
    final rates = {
      'whatsapp_utility': 0.35,
      'whatsapp_marketing': 0.85,
      'twilio_voice_min': 1.80,
      'gemini_live_min': 2.40,
      'sms_failover': 0.28,
    };
    final unitRate = rates[serviceName] ?? 0.50;
    final totalCost = double.parse((unitRate * units).toStringAsFixed(4));

    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;
    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('record_cost_event', params: {
          'p_request_id': requestId,
          'p_service_name': serviceName,
          'p_units': units,
          'p_meta': meta ?? {},
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('recordCostEvent error: $e');
      }
    }

    return {
      'ok': true,
      'event_id': 'cost-${DateTime.now().millisecondsSinceEpoch}',
      'unit_rate': unitRate,
      'total_cost_inr': totalCost,
    };
  }

  /// Get daily spend summary with breakdown by channel in INR
  Future<Map<String, dynamic>> getDailySpendSummary({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final dateStr = target.toIso8601String().substring(0, 10);
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final res = await client.rpc('get_daily_spend_summary', params: {
          'p_target_date': dateStr,
        });
        if (res != null && res is Map<String, dynamic>) {
          return res;
        }
      } catch (e) {
        debugPrint('getDailySpendSummary error: $e');
      }
    }

    return {
      'target_date': dateStr,
      'total_spend_inr': 48.75,
      'breakdown': [
        {
          'service_name': 'whatsapp_utility',
          'count': 45,
          'units': 45,
          'total_inr': 15.75
        },
        {
          'service_name': 'twilio_voice_min',
          'count': 10,
          'units': 12.5,
          'total_inr': 22.50
        },
        {
          'service_name': 'gemini_live_min',
          'count': 3,
          'units': 4.38,
          'total_inr': 10.50
        },
      ],
    };
  }
}
