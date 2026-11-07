// ============================================================================
// BloodNorms | admin_merge_test.dart
// Milestone AM0 Verification: Merge Log Completeness & Permission Scaffolding
// ============================================================================

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnorms/shared/services/supabase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Milestone AM0: Inventory & Merge Log Verification', () {
    test('docs/ADMIN-INVENTORY.md exists and documents baseline routes, screens, and functions', () {
      final inventoryFile = File('docs/ADMIN-INVENTORY.md');
      expect(inventoryFile.existsSync(), isTrue, reason: 'ADMIN-INVENTORY.md must exist');
      final content = inventoryFile.readAsStringSync();
      expect(content.contains('/admin'), isTrue);
      expect(content.contains('AdminConsoleScreen'), isTrue);
      expect(content.contains('is_admin'), isTrue);
      expect(content.contains('kill_switch_active'), isTrue);
    });

    test('docs/ADMIN-MERGE-LOG.md exists and contains all required module IDs', () {
      final mergeLogFile = File('docs/ADMIN-MERGE-LOG.md');
      expect(mergeLogFile.existsSync(), isTrue, reason: 'ADMIN-MERGE-LOG.md must exist');
      final content = mergeLogFile.readAsStringSync();

      // Check key milestone and module requirements
      final requiredIds = [
        'ROL-1', 'ROL-2', 'ROL-3', 'ROL-4', 'APR-1', 'APR-2',
        'MNT-1', 'MNT-2', 'MNT-3', 'MNT-4', 'MNT-5', 'MNT-6', 'MNT-7', 'MNT-8', 'MNT-9', 'MNT-10',
        'EXP-1', 'EXP-2', 'EXP-3', 'EXP-4', 'EXP-5', 'EXP-6', 'EXP-7', 'EXP-8', 'EXP-9', 'EXP-10',
        'CMD-1', 'CMD-2', 'CMD-3', 'CMD-6',
        'LIV-1', 'LIV-2', 'LIV-5', 'LIV-7',
        'NHD-1', 'NHD-2', 'NHD-3',
        'DON-A1', 'DON-A3', 'DON-A5', 'DON-A9',
        'BNK-A1', 'BNK-A2', 'BNK-A3', 'BNK-A5',
        'WAC-1', 'WAC-3', 'WAC-9',
        'CAL-1', 'CAL-4',
        'AIV-1', 'AIV-2', 'AIV-3', 'AIV-5',
        'ENG-A1', 'ENG-A6',
        'CNT-1', 'CNT-4',
        'SAF-1', 'SAF-4', 'SAF-6',
        'ANL-1', 'FIN-1', 'SYS-1', 'ADU-1', 'ADU-2',
        'PRT-1', 'KIT-1', 'SBX-1', 'ALR-1', 'AUT-1', 'DQ-1', 'REL-1', 'GSR-1'
      ];

      for (final reqId in requiredIds) {
        expect(content.contains(reqId), isTrue, reason: 'Requirement ID $reqId must be logged in merge log');
      }
    });

    test('Progressive expansion feature flags default to false (OFF in production)', () async {
      final service = SupabaseService();

      final rbacEnabled = await service.isFeatureEnabled('flag_advanced_rbac');
      expect(rbacEnabled, isFalse);

      final maintenanceEnabled = await service.isFeatureEnabled('flag_scoped_maintenance');
      expect(maintenanceEnabled, isFalse);

      final exportEngineEnabled = await service.isFeatureEnabled('flag_data_export_engine');
      expect(exportEngineEnabled, isFalse);
    });

    test('Master built-in admin roles contain all 10 mandated roles', () async {
      final service = SupabaseService();
      final roles = await service.getAdminRoles();

      expect(roles.length, 10);
      final roleIds = roles.map((r) => r['id']).toSet();
      expect(roleIds.contains('super_admin'), isTrue);
      expect(roleIds.contains('admin'), isTrue);
      expect(roleIds.contains('support'), isTrue);
      expect(roleIds.contains('oncall'), isTrue);
      expect(roleIds.contains('bank_manager'), isTrue);
      expect(roleIds.contains('content_editor'), isTrue);
      expect(roleIds.contains('clinical_reviewer'), isTrue);
      expect(roleIds.contains('legal_officer'), isTrue);
      expect(roleIds.contains('analyst'), isTrue);
      expect(roleIds.contains('finance'), isTrue);
    });

    test('Permission check defaults to deny for mutation actions when unauthenticated', () async {
      final service = SupabaseService();
      final canDelete = await service.hasAdminPermission('donors.delete');
      expect(canDelete, isFalse);

      final canExportFull = await service.hasAdminPermission('exports.export_full');
      expect(canExportFull, isFalse);
    });
  });
}

