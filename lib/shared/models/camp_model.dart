// ============================================================================
// BloodNorms | shared/models/camp_model.dart
//
// Data model for a blood donation camp (voluntary blood drive).
// Used by DonorCampsScreen, BankConsoleScreen, and AdminConsoleScreen.
// Deserialized from the `bank_camps` Supabase table.
// ============================================================================

/// A scheduled blood donation drive organized by a blood bank.
class CampModel {
  final String id;
  final String bankId;
  final String title;
  final String venue;
  final String area;
  final String city;
  final String district;
  final String pincode;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;

  /// Lifecycle status: 'draft', 'published', 'in_progress', 'completed', 'cancelled'.
  final String status;

  final double lat;
  final double lng;

  // Alias getters for screens that use nullable lat/lng convention
  double? get latitude => lat;
  double? get longitude => lng;

  final int attendeesCheckedIn;
  final int unitsCollected;

  /// Target broadcast radius for donor notifications (km).
  final double targetRadiusKm;

  final String? directionsUrl;
  final String? coordinatorName;
  final String? coordinatorPhone;

  const CampModel({
    required this.id,
    required this.bankId,
    required this.title,
    required this.venue,
    required this.area,
    this.city = 'Rajahmundry',
    this.district = 'East Godavari',
    this.pincode = '533101',
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.status,
    required this.lat,
    required this.lng,
    this.attendeesCheckedIn = 0,
    this.unitsCollected = 0,
    this.targetRadiusKm = 10.0,
    this.directionsUrl,
    this.coordinatorName,
    this.coordinatorPhone,
  });

  factory CampModel.fromJson(Map<String, dynamic> json) {
    return CampModel(
      id: json['id']?.toString() ?? '',
      bankId: json['bank_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Blood Donation Camp',
      venue: json['venue']?.toString() ?? 'Community Hall',
      area: json['area']?.toString() ?? 'Rajahmundry',
      city: json['city']?.toString() ?? 'Rajahmundry',
      district: json['district']?.toString() ?? 'East Godavari',
      pincode: json['pincode']?.toString() ?? '533101',
      startsAt: json['starts_at'] != null ? DateTime.tryParse(json['starts_at'].toString()) ?? DateTime.now() : DateTime.now(),
      endsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'].toString()) ?? DateTime.now() : DateTime.now(),
      capacity: (json['capacity'] as num?)?.toInt() ?? 100,
      status: json['status']?.toString() ?? 'published',
      lat: (json['lat'] as num?)?.toDouble() ?? 17.0005,
      lng: (json['lng'] as num?)?.toDouble() ?? 81.7800,
      attendeesCheckedIn: (json['attendees_checked_in'] as num?)?.toInt() ?? 0,
      unitsCollected: (json['units_collected'] as num?)?.toInt() ?? 0,
      targetRadiusKm: (json['target_radius_km'] as num?)?.toDouble() ?? 10.0,
      directionsUrl: json['directions_url']?.toString(),
      coordinatorName: json['coordinator_name']?.toString(),
      coordinatorPhone: json['coordinator_phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_id': bankId,
      'title': title,
      'venue': venue,
      'area': area,
      'city': city,
      'district': district,
      'pincode': pincode,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'capacity': capacity,
      'status': status,
      'lat': lat,
      'lng': lng,
      'attendees_checked_in': attendeesCheckedIn,
      'units_collected': unitsCollected,
      'target_radius_km': targetRadiusKm,
      'directions_url': directionsUrl,
      'coordinator_name': coordinatorName,
      'coordinator_phone': coordinatorPhone,
    };
  }
}

