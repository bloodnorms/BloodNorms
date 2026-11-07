// ============================================================================
// BloodNorms | phone_utils.dart
// Phone normalization and privacy masking utilities for Indian numbers
// ============================================================================

class PhoneUtils {
  /// Normalize phone number to Meta's expected digits-only format (e.g. 91XXXXXXXXXX)
  static String normalizePhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
    if (cleaned.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      cleaned = '91$cleaned';
    }
    return cleaned;
  }

  /// Mask phone number for DPDP compliance logging
  static String maskPhoneForAudit(String phone) {
    final cleaned = normalizePhone(phone);
    if (cleaned.length >= 10) {
      final prefix = cleaned.substring(0, cleaned.length - 5);
      return '+$prefix •••••';
    }
    return '••••••••••';
  }
}
