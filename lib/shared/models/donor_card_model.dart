// ============================================================================
// BloodNorms | shared/models/donor_card_model.dart
//
// Data model for a donor shown in the Live Tracking radar and donor alert
// screens. Includes distance band, ETA, status, and optional phone reveal.
// Deserialized from the `get_donors_for_request` Supabase RPC.
// ============================================================================

/// A donor who has been matched to an emergency blood request.
class DonorCardModel {
  final String id;
  final String firstName;
  final String bloodGroup;

  /// Human-readable distance band, e.g. "< 2.5 km".
  final String distanceBand;

  /// Estimated arrival time in minutes (derived from distance).
  final int etaMinutes;

  /// Lifecycle status: 'accepted', 'declined', 'standby', etc.
  final String status;

  /// Whether this donor is on the standby (non-primary) wave.
  final bool isStandby;

  /// Whether the requester has revealed the donor's phone number.
  final bool phoneRevealed;

  final String? phone;
  final String? donationCode;
  final double? latitude;
  final double? longitude;

  /// Latitude with pilot-city fallback.
  double get lat => latitude ?? 17.0005;

  /// Longitude with pilot-city fallback.
  double get lng => longitude ?? 81.7800;

  const DonorCardModel({
    required this.id,
    required this.firstName,
    required this.bloodGroup,
    required this.distanceBand,
    required this.etaMinutes,
    required this.status,
    required this.isStandby,
    required this.phoneRevealed,
    this.phone,
    this.donationCode,
    this.latitude,
    this.longitude,
  });

  /// Parses a donor card from the JSON shape returned by the matching engine.
  factory DonorCardModel.fromJson(Map<String, dynamic> json) {
    final distKm = (json['distance_km'] ?? json['ring_km'] as num?)?.toDouble();
    final distBand = json['distance_band']?.toString() ??
        (distKm != null ? '< ${(distKm + 0.5).toStringAsFixed(1)} km' : '< 3 km');

    return DonorCardModel(
      id: (json['id'] ?? json['donor_id'])?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? 'Donor',
      bloodGroup: json['blood_group']?.toString() ?? 'O+',
      distanceBand: distBand,
      // ETA: 8 minutes per km, clamped between 10 and 45 minutes
      etaMinutes: (distKm != null ? (distKm * 8).toInt().clamp(10, 45) : (json['eta_minutes'] as num?)?.toInt() ?? 25),
      status: json['status']?.toString() ?? 'accepted',
      isStandby: json['is_standby'] == true,
      phoneRevealed: json['phone_revealed'] == true || (json['phone'] != null),
      phone: json['phone']?.toString(),
      donationCode: json['donation_code']?.toString(),
      latitude: (json['lat'] ?? json['home_lat']) != null ? ((json['lat'] ?? json['home_lat']) as num).toDouble() : null,
      longitude: (json['lng'] ?? json['home_lng']) != null ? ((json['lng'] ?? json['home_lng']) as num).toDouble() : null,
    );
  }
}

