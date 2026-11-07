// ============================================================================
// BloodNorms | rings.dart
// Search rings (km), gates, wave durations per BR-06, BR-07, BR-08
// ============================================================================

class SearchRings {
  // BR-06: 0.5, 1, 2, 3, 5, 10, 15, 20, 30, 40, 50, 70, 90, 100 km
  static const List<double> ringsKm = [
    0.5,
    1.0,
    2.0,
    3.0,
    5.0,
    10.0,
    15.0,
    20.0,
    30.0,
    40.0,
    50.0,
    70.0,
    90.0,
    100.0,
  ];

  // BR-07: Gates at 70, 90, 100 km requiring requester confirmation
  static const List<double> gateRingsKm = [70.0, 90.0, 100.0];

  static bool isGateRing(double km) {
    return gateRingsKm.contains(km);
  }

  // BR-08: Wave wait before widening
  static Duration waveDuration(String urgency) {
    switch (urgency) {
      case 'now':
        return const Duration(minutes: 3);
      case 'within_6h':
        return const Duration(minutes: 8);
      case 'within_24h':
        return const Duration(minutes: 20);
      case 'planned':
      default:
        return const Duration(minutes: 60);
    }
  }

  // Distance band formatting (for privacy: never exact distance to donor)
  static String formatDistanceBand(double km) {
    if (km <= 1.0) return '< 1 km';
    if (km <= 3.0) return '1–3 km';
    if (km <= 5.0) return '3–5 km';
    if (km <= 10.0) return '5–10 km';
    if (km <= 25.0) return '10–25 km';
    if (km <= 50.0) return '25–50 km';
    return '50–100 km';
  }
}

