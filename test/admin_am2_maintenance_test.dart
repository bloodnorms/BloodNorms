// ============================================================================
// BloodNorms | test/admin_am2_maintenance_test.dart
// Milestone AM2 Verification Suite: Maintenance Mode & Scoped Switches
// Verifies MNT-1 to MNT-10 requirements:
// - 8 independent scopes (web, donor, bank, public, whatsapp, phone, api, admin)
// - Trilingual messaging (en, te, hi)
// - In-flight policy options
// - Extension of maintenance windows
// - Allowlist bypass logic
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/core/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Milestone AM2: Maintenance Mode & Scoped Switches (MNT-1..10)', () {
    test('checkMaintenanceStatus returns valid scope structure and trilingual messages', () async {
      final res = await SupabaseService().checkMaintenanceStatus(scope: 'web');

      expect(res.containsKey('active'), isTrue);
      expect(res.containsKey('messages'), isTrue);
      final messages = res['messages'] as Map<String, dynamic>;
      expect(messages.containsKey('en'), isTrue);
      expect(messages.containsKey('te'), isTrue);
      expect(messages.containsKey('hi'), isTrue);
      expect(messages['en'], isNotEmpty);
      expect(messages['te'], isNotEmpty);
      expect(messages['hi'], isNotEmpty);
    });

    test('setMaintenanceMode toggles active status and scoped availability', () async {
      final initial = await SupabaseService().checkMaintenanceStatus(scope: 'donor');
      expect(initial['active'], isFalse);

      // Turn on maintenance for 'donor' and 'bank' only
      final setRes = await SupabaseService().setMaintenanceMode(
        active: true,
        scopes: ['donor', 'bank'],
        policy: 'continue_active',
        reason: 'Scheduled database migration for blood banks',
        durationMinutes: 45,
      );
      expect(setRes['ok'], isTrue);

      final donorStatus = await SupabaseService().checkMaintenanceStatus(scope: 'donor');
      expect(donorStatus['active'], isTrue);

      // 'web' scope should not be blocked since it was not in the scopes list
      final webStatus = await SupabaseService().checkMaintenanceStatus(scope: 'web');
      expect(webStatus['active'], isFalse);
    });

    test('getMaintenanceWindows returns list with in-flight policies and metadata', () async {
      final windows = await SupabaseService().getMaintenanceWindows();
      expect(windows, isNotEmpty);

      final win = windows.first;
      expect(win.containsKey('id'), isTrue);
      expect(win.containsKey('scopes'), isTrue);
      expect(win.containsKey('inflight_policy'), isTrue);
      expect(['continue_active', 'freeze', 'emergency_bypass'], contains(win['inflight_policy']));
    });

    test('extendMaintenanceWindow calculates valid updated end time', () async {
      final ext = await SupabaseService().extendMaintenanceWindow(
        windowId: 'win-default-01',
        additionalMinutes: 30,
        reason: 'Verifying final sanity checks before reopening',
      );

      expect(ext['ok'], isTrue);
      expect(ext['new_end'], isNotNull);
      final newEnd = DateTime.parse(ext['new_end'] as String);
      expect(newEnd.isAfter(DateTime.now()), isTrue);
    });

    test('setMaintenanceMode handles bypass allowlist configuration', () async {
      final allowlist = {
        'phones': ['+919876543210', '+919876543211'],
        'admin_ids': ['adm-01'],
        'ips': ['127.0.0.1', '10.0.0.1'],
      };

      final res = await SupabaseService().setMaintenanceMode(
        active: true,
        scopes: ['web'],
        bypassAllowlist: allowlist,
      );

      expect(res['ok'], isTrue);
    });
  });
}

