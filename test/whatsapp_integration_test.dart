// ============================================================================
// BloodNorms | test/whatsapp_integration_test.dart
// Meta WhatsApp Cloud API Service & Test Bench Test Suite
// ============================================================================

import 'package:bloodnorms/core/services/whatsapp_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsApp Cloud API Service & Verification Test Suite', () {
    test('1. Phone number normalization converts various formats to Meta digits-only format', () {
      expect(WhatsAppService.normalizePhone('9052493747'), '919052493747');
      expect(WhatsAppService.normalizePhone('+91 90524 93747'), '919052493747');
      expect(WhatsAppService.normalizePhone('+91-90524-93747'), '919052493747');
      expect(WhatsAppService.normalizePhone('919052493747'), '919052493747');
      expect(WhatsAppService.normalizePhone('+1 (555) 234-5678'), '15552345678');
    });

    test('2. Phone masking for DPDP privacy audit adheres to standard compliance', () {
      expect(WhatsAppService.maskPhoneForAudit('9052493747'), '+9190524 •••••');
      expect(WhatsAppService.maskPhoneForAudit('+91 90524 93747'), '+9190524 •••••');
    });

    test('3. Detects when Phone Number ID is accidentally a 10-digit mobile number', () {
      final service = WhatsAppService();
      service.setRuntimeCredentials(
        phoneNumberId: '9052493747',
        accessToken: 'test_token',
      );

      final config = service.getConfig();
      expect(config.isPhoneNumberIdLikelyMobile, isTrue);
      expect(config.isConfigured, isTrue);
      expect(config.phoneNumberId, '9052493747');
    });

    test('4. Accepts valid 15-digit Meta Graph API Phone Number ID', () {
      final service = WhatsAppService();
      service.setRuntimeCredentials(
        phoneNumberId: '105493829104829',
        accessToken: 'test_token_valid',
      );

      final config = service.getConfig();
      expect(config.isPhoneNumberIdLikelyMobile, isFalse);
      expect(config.isConfigured, isTrue);
      expect(config.phoneNumberId, '105493829104829');
    });

    test('5. Reports unconfigured status with clear diagnostic when credentials missing', () async {
      final service = WhatsAppService();
      service.setRuntimeCredentials(
        phoneNumberId: '',
        accessToken: '',
      );

      final res = await service.sendTemplateMessage(
        toPhone: '9052493747',
        templateName: 'hello_world',
      );

      expect(res.success, isFalse);
      expect(res.statusCode, 400);
      expect(res.errorSummary, contains('not configured'));
    });

    test('6. Masks access token properly for UI and logs', () {
      final service = WhatsAppService();
      service.setRuntimeCredentials(
        phoneNumberId: '105493829104829',
        accessToken: 'EAAB1234567890abcdef',
      );

      final config = service.getConfig();
      expect(config.maskedToken, startsWith('EAAB12'));
      expect(config.maskedToken, endsWith('cdef'));
      expect(config.maskedToken, contains('••••'));
    });
  });
}
