// ============================================================================
// BloodNorms | prescription_slip_service.dart
// Upload and retrieval of medical prescription slips from Supabase Storage
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/services/supabase_service.dart';

class PrescriptionSlipService {
  static final PrescriptionSlipService _instance =
      PrescriptionSlipService._internal();
  factory PrescriptionSlipService() => _instance;
  PrescriptionSlipService._internal();

  SupabaseClient? get _client => SupabaseService().client;

  /// Upload prescription slip image to Supabase Storage
  Future<String?> uploadPrescriptionSlip({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = _client;
    if (client != null) {
      try {
        final path = 'slips/$fileName';
        await client.storage.from('slips').uploadBinary(
              path,
              bytes,
              fileOptions: const FileOptions(upsert: true),
            );
        return client.storage.from('slips').getPublicUrl(path);
      } catch (e) {
        debugPrint('uploadPrescriptionSlip error: $e');
      }
    }
    return null;
  }
}
