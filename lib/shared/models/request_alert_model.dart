// ============================================================================
// BloodNorms | shared/models/request_alert_model.dart
//
// Data model for a blood request alert sent to donors.
// Contains the minimum information a donor needs to decide whether to accept
// (blood group, units, hospital, urgency, distance).
// Deserialized from the `requests` table via the matching engine.
// ============================================================================

/// A blood request alert dispatched to a donor's device.
class RequestAlertModel {
  final String id;
  final String patientFirstName;
  final String bloodGroup;
  final String component;
  final int unitsNeeded;

  /// Urgency level: 'now' (< 2h), 'today' (< 12h), or 'scheduled'.
  final String urgency;

  final String hospitalName;
  final String hospitalArea;

  /// Hospital GPS coordinates for distance calculation.
  final double lat;
  final double lng;

  final String requesterName;

  /// Masked requester phone — not the full number at alert stage.
  final String requesterPhone;

  final DateTime createdAt;

  const RequestAlertModel({
    required this.id,
    required this.patientFirstName,
    required this.bloodGroup,
    required this.component,
    required this.unitsNeeded,
    required this.urgency,
    required this.hospitalName,
    required this.hospitalArea,
    required this.lat,
    required this.lng,
    required this.requesterName,
    required this.requesterPhone,
    required this.createdAt,
  });

  factory RequestAlertModel.fromJson(Map<String, dynamic> json) {
    return RequestAlertModel(
      id: json['id']?.toString() ?? '',
      patientFirstName: json['patient_first_name']?.toString() ?? 'Patient',
      bloodGroup: json['blood_group']?.toString() ?? 'O+',
      component: json['component']?.toString() ?? 'whole_blood',
      unitsNeeded: (json['units_needed'] as num?)?.toInt() ?? 1,
      urgency: json['urgency']?.toString() ?? 'now',
      hospitalName: json['hospital_name']?.toString() ?? 'General Hospital',
      hospitalArea: json['hospital_area']?.toString() ?? 'Rajahmundry',
      lat: (json['hospital_lat'] as num?)?.toDouble() ?? 17.0005,
      lng: (json['hospital_lng'] as num?)?.toDouble() ?? 81.7800,
      requesterName: json['requester_name']?.toString() ?? 'Family',
      requesterPhone: json['requester_phone']?.toString() ?? '+919848123456',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}

