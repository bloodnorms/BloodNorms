// ============================================================================
// BloodNorms | lib/shared/constants/app_error_catalog.dart
//
// Centralized, trilingual, patient-safe error and message catalog.
// Provides domain error codes, localized copy, and clear recovery actions.
// ============================================================================

/// Definition of a standardized application error entry.
class AppErrorEntry {
  final String code;
  final String en;
  final String te;
  final String hi;
  final String recoveryAction;

  const AppErrorEntry({
    required this.code,
    required this.en,
    required this.te,
    required this.hi,
    required this.recoveryAction,
  });
}

/// Catalog of all standardized user-facing and operational errors.
class AppErrorCatalog {
  static const Map<String, AppErrorEntry> entries = {
    'AUTH_001': AppErrorEntry(
      code: 'AUTH_001',
      en: 'Your session has expired. Please verify your phone number again.',
      te: 'మీ సెషన్ ముగిసింది. దయచేసి మీ ఫోన్ నంబర్‌ను మళ్లీ ధృవీకరించండి.',
      hi: 'आपका सत्र समाप्त हो गया है। कृपया अपना फोन नंबर पुनः सत्यापित करें।',
      recoveryAction: 'Re-authenticate with OTP',
    ),
    'MATCH_001': AppErrorEntry(
      code: 'MATCH_001',
      en: 'No matching donors found in the immediate radius. Expanding to the next ring.',
      te: 'సమీప పరిధిలో సరిపోయే దాతలు కనుగొనబడలేదు. తదుపరి సర్కిల్‌కు విస్తరిస్తోంది.',
      hi: 'निकटतम दायरे में कोई मेल खाने वाला दाता नहीं मिला। अगले दायरे में विस्तार किया जा रहा है।',
      recoveryAction: 'Automatic ring expansion in progress',
    ),
    'GEO_001': AppErrorEntry(
      code: 'GEO_001',
      en: 'Location access is required to locate nearest blood banks and donors.',
      te: 'సమీపంలోని బ్లడ్ బ్యాంకులు మరియు దాతలను గుర్తించడానికి లొకేషన్ యాక్సెస్ అవసరం.',
      hi: 'निकटतम रक्त बैंकों और दाताओं का पता लगाने के लिए स्थान अनुमति आवश्यक है।',
      recoveryAction: 'Enable GPS location permissions in device settings',
    ),
    'TELEPHONY_001': AppErrorEntry(
      code: 'TELEPHONY_001',
      en: 'Helpline audio stream could not be established. Falling back to keypad IVR.',
      te: 'హెల్ప్‌లైన్ ఆడియోను ప్రారంభించలేకపోయాము. కీప్యాడ్ IVRకి మళ్లించబడుతోంది.',
      hi: 'हेल्पलाइन ऑडियो स्थापित नहीं किया जा सका। कीपैड IVR पर वापस जाया जा रहा है।',
      recoveryAction: 'Press digits on keypad for trilingual options',
    ),
    'GOV_001': AppErrorEntry(
      code: 'GOV_001',
      en: 'Four-eyes security violation: Requester cannot approve their own change.',
      te: 'నాలుగు కళ్ల భద్రతా నియమం: అభ్యర్థించిన వారే ఆమోదించలేరు.',
      hi: 'चार-आंखों का सुरक्षा उल्लंघन: अनुरोधकर्ता स्वयं परिवर्तन स्वीकृत नहीं कर सकता।',
      recoveryAction: 'Assign to a secondary verified administrator for review',
    ),
    'MNT_001': AppErrorEntry(
      code: 'MNT_001',
      en: 'BloodNorms is currently undergoing scheduled maintenance.',
      te: 'బ్లడ్‌నార్మ్స్ ప్రస్తుతం షెడ్యూల్ చేసిన నిర్వహణలో ఉంది.',
      hi: 'ब्लडनॉर्म्स वर्तमान में निर्धारित रखरखाव से गुजर रहा है।',
      recoveryAction: 'For life-threatening emergencies, dial 108 or visit nearest hospital',
    ),
  };

  /// Returns the localized error message or falls back to English.
  static String getLocalizedMessage(String code, [String languageCode = 'en']) {
    final entry = entries[code];
    if (entry == null) {
      return 'An unexpected error occurred. Please call our emergency helpline.';
    }

    switch (languageCode) {
      case 'te':
        return entry.te;
      case 'hi':
        return entry.hi;
      default:
        return entry.en;
    }
  }

  /// Returns recovery action guidance.
  static String getRecoveryAction(String code) {
    return entries[code]?.recoveryAction ?? 'Contact technical support';
  }
}
