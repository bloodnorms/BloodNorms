// ============================================================================
// BloodNorms | app_constants.dart
// Product name, rules constants, constraints
// ============================================================================

class AppConstants {
  static const String appName = 'BloodNorms';
  static const String pilotCity = 'Rajahmundry';
  static const String pilotState = 'Andhra Pradesh';
  static const String supportPhone = '+918832471234';
  static const String ambulanceEmergency = '108';

  // Rule BR-01: Donor age and weight
  static const int minDonorAge = 18;
  static const int maxDonorAge = 65;
  static const double minDonorWeightKg = 45.0;

  // Rule BR-02: Donation cooling periods (months)
  static const int maleCoolingMonths = 3;
  static const int femaleCoolingMonths = 4;

  // Rule BR-03: Donor fatigue limits
  static const int minHoursBetweenRequests = 6;
  static const int maxRequestsIn7Days = 3;
  static const int defaultMonthlyCap = 4;

  // Rule BR-05: Wave contact multiplier and caps
  static const int contactMultiplier = 3;
  static const int maxContactsPerRequest = 30;

  // Rule BR-16: Requester limits
  static const int maxRequestsPerDay = 3;

  // India geographical bounding box
  static const double minIndiaLat = 6.0;
  static const double maxIndiaLat = 38.0;
  static const double minIndiaLng = 68.0;
  static const double maxIndiaLng = 98.0;

  // Default Rajahmundry coordinates
  static const double defaultLat = 17.0005;
  static const double defaultLng = 81.7820;

  // Supabase defaults (can be overridden via environment/dotenv)
  static const String defaultSupabaseUrl = 'https://xyzcompany.supabase.co';
  static const String defaultSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy';
}

