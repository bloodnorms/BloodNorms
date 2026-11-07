// ============================================================================
// BloodNorms | shared/models/blood_bank_model.dart
//
// Data model for a blood bank, including stock, trust score, and location.
// Deserialized from the `find_nearby_banks_with_stock` and `nearest_banks`
// Supabase RPCs. Used by BanksListScreen, PublicBanksScreen, and
// LiveTrackingScreen.
// ============================================================================

import '../constants/app_constants.dart';

/// A blood bank with its current stock level, location, and trust score.
class BloodBankModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String? district;
  final List<String> phones;
  final bool is24x7;
  final double distanceKm;
  final int stockUnits;
  final String stockFreshness;
  final int trustScore;
  final String trustLabel;
  final DateTime? stockUpdatedAt;
  final double? latitude;
  final double? longitude;

  // Convenience getters
  /// Latitude with deterministic fallback based on bank ID hash.
  double get lat => latitude ?? (16.9890 + (id.hashCode % 10) * 0.003);

  /// Longitude with deterministic fallback based on bank ID hash.
  double get lng => longitude ?? (81.7840 + (id.hashCode % 10) * 0.003);

  /// Distance in meters (for callers that prefer SI units).
  double get distanceMeters => distanceKm * 1000;

  /// Alias for stockUnits (used by some screens).
  int get unitsAvailable => stockUnits;

  /// Whether the bank operates around the clock.
  bool get isOpen24x7 => is24x7;

  /// Primary phone number, with the emergency helpline as final fallback.
  String get phone => phones.isNotEmpty ? phones.first : '+91 883 2471234';

  const BloodBankModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.district,
    required this.phones,
    required this.is24x7,
    required this.distanceKm,
    required this.stockUnits,
    required this.stockFreshness,
    required this.trustScore,
    required this.trustLabel,
    this.stockUpdatedAt,
    this.latitude,
    this.longitude,
  });

  /// Parses a blood bank from the JSON shape returned by both RPCs.
  /// Handles both `bank_id`/`bank_name` (RPC v1) and `id`/`name` (RPC v2).
  factory BloodBankModel.fromJson(Map<String, dynamic> json) {
    final rawPhones = json['phones'];
    List<String> parsedPhones = [];
    if (rawPhones is List) {
      parsedPhones = rawPhones.map((e) => e.toString()).toList();
    } else if (rawPhones is String && rawPhones.isNotEmpty) {
      parsedPhones = [rawPhones];
    }

    final rawTrust = json['trust_score'];
    int parsedTrust = 80;
    if (rawTrust is num) {
      parsedTrust = rawTrust.toInt();
    } else if (rawTrust is String) {
      parsedTrust = double.tryParse(rawTrust)?.toInt() ?? 80;
    }

    final units = ((json['units_available'] ?? json['stock_units'] ?? json['units']) as num?)?.toInt() ?? 0;

    return BloodBankModel(
      id: (json['bank_id'] ?? json['id'])?.toString() ?? '',
      name: (json['bank_name'] ?? json['name'])?.toString() ?? 'Blood Bank',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? AppConstants.pilotCity,
      district: json['district']?.toString(),
      phones: parsedPhones,
      is24x7: json['is_24x7'] == true,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.5,
      stockUnits: units,
      stockFreshness: json['stock_freshness']?.toString() ?? (units > 0 ? 'verified' : 'fresh'),
      trustScore: parsedTrust,
      trustLabel: parsedTrust >= 85 ? 'Reliable' : (parsedTrust >= 70 ? 'OK' : 'Unverified'),
      stockUpdatedAt: (json['stock_updated_at'] ?? json['updated_at']) != null
          ? DateTime.tryParse((json['stock_updated_at'] ?? json['updated_at']).toString())
          : null,
      latitude: (json['lat'] ?? json['latitude']) != null
          ? ((json['lat'] ?? json['latitude']) as num).toDouble()
          : null,
      longitude: (json['lng'] ?? json['longitude']) != null
          ? ((json['lng'] ?? json['longitude']) as num).toDouble()
          : null,
    );
  }
}

