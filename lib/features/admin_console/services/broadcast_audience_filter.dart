// ============================================================================
// BloodNorms | broadcast_audience_filter.dart
// Fallback geo-targeted audience calculation and candidate donors pool
// ============================================================================

import '../../../shared/utils/geo_utils.dart';

const List<Map<String, dynamic>> kCandidateBroadcastDonors = [
  {'id': 'dn-001', 'full_name': 'Ravi Teja Varma', 'phone': '+91 98480 12345', 'blood_group': 'O+', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Danavaipeta', 'lat': 17.0050, 'lng': 81.7950, 'travel_radius_km': 15.0, 'is_away': false},
  {'id': 'dn-002', 'full_name': 'Ananya Krishna', 'phone': '+91 94401 56789', 'blood_group': 'A-', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Morampudi', 'lat': 17.0180, 'lng': 81.7920, 'travel_radius_km': 10.0, 'is_away': false},
  {'id': 'dn-003', 'full_name': 'K. Suresh Kumar', 'phone': '+91 98660 98765', 'blood_group': 'B+', 'state': 'active', 'city': 'Kakinada', 'area': 'Bhanugudi', 'lat': 16.9891, 'lng': 82.2475, 'travel_radius_km': 20.0, 'is_away': false},
  {'id': 'dn-004', 'full_name': 'Deepika Reddy', 'phone': '+91 88324 11223', 'blood_group': 'AB+', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Aryapuram', 'lat': 17.0120, 'lng': 81.8150, 'travel_radius_km': 5.0, 'is_away': false},
  {'id': 'dn-005', 'full_name': 'Venkatesh Rao', 'phone': '+91 99887 76655', 'blood_group': 'O-', 'state': 'active', 'city': 'Visakhapatnam', 'area': 'MVP Colony', 'lat': 17.7042, 'lng': 83.3032, 'travel_radius_km': 25.0, 'is_away': false},
  {'id': 'dn-006', 'full_name': 'Lakshmi Narayana', 'phone': '+91 98765 43210', 'blood_group': 'O+', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Kambala Tank', 'lat': 17.0010, 'lng': 81.8020, 'travel_radius_km': 12.0, 'is_away': false},
  {'id': 'dn-007', 'full_name': 'M. Sai Praneeth', 'phone': '+91 98490 88776', 'blood_group': 'A+', 'state': 'active', 'city': 'Kakinada', 'area': 'Main Road', 'lat': 16.9604, 'lng': 82.2381, 'travel_radius_km': 15.0, 'is_away': false},
  {'id': 'dn-008', 'full_name': 'P. Haritha', 'phone': '+91 94901 22334', 'blood_group': 'B-', 'state': 'active', 'city': 'Visakhapatnam', 'area': 'Gajuwaka', 'lat': 17.6900, 'lng': 83.2090, 'travel_radius_km': 10.0, 'is_away': false},
  {'id': 'dn-009', 'full_name': 'Ch. Jagadeesh', 'phone': '+91 91234 56789', 'blood_group': 'O+', 'state': 'active', 'city': 'Vijayawada', 'area': 'Benz Circle', 'lat': 16.5062, 'lng': 80.6480, 'travel_radius_km': 20.0, 'is_away': false},
  {'id': 'dn-010', 'full_name': 'B. Swathi', 'phone': '+91 97000 11223', 'blood_group': 'AB-', 'state': 'active', 'city': 'Rajahmundry', 'area': 'Lalacheruvu', 'lat': 17.0320, 'lng': 81.8100, 'travel_radius_km': 8.0, 'is_away': true},
];

Map<String, dynamic> computeLocalAudience({
  required double effectiveLat,
  required double effectiveLng,
  required String targetCity,
  required double radiusKm,
  required bool respectTravelCap,
  required String bloodGroup,
  required String channel,
  String? campId,
  String venueName = 'Designated Center',
}) {
  final eligible = <Map<String, dynamic>>[];
  final suppressedDonors = <Map<String, dynamic>>[];
  final areaBreakdown = <String, int>{};
  final suppressionSummary = <String, int>{};

  for (final d in kCandidateBroadcastDonors) {
    if (d['state'] != 'active') continue;
    final dCity = d['city'].toString();
    final dArea = d['area']?.toString() ?? 'Area';
    final dLat = (d['lat'] as num?)?.toDouble() ?? 17.0005;
    final dLng = (d['lng'] as num?)?.toDouble() ?? 81.8040;
    final distKm = calculateHaversineDistanceKm(effectiveLat, effectiveLng, dLat, dLng);
    final maxRad = (d['travel_radius_km'] as num?)?.toDouble() ?? 15.0;
    final isAway = d['is_away'] == true;

    if (isAway) {
      suppressionSummary['out_of_town'] = (suppressionSummary['out_of_town'] ?? 0) + 1;
      suppressedDonors.add({
        'id': d['id'],
        'name': d['full_name'],
        'blood_group': d['blood_group'],
        'city': dCity,
        'distance_km': double.parse(distKm.toStringAsFixed(1)),
        'reason': 'Donor is currently marked Out of Station / Away',
      });
      continue;
    }

    if (bloodGroup != 'All' && d['blood_group'] != bloodGroup) {
      suppressionSummary['blood_mismatch'] = (suppressionSummary['blood_mismatch'] ?? 0) + 1;
      suppressedDonors.add({
        'id': d['id'],
        'name': d['full_name'],
        'blood_group': d['blood_group'],
        'city': dCity,
        'distance_km': double.parse(distKm.toStringAsFixed(1)),
        'reason': 'Blood group mismatch (${d['blood_group']})',
      });
      continue;
    }

    if (targetCity != 'All' && !dCity.toLowerCase().contains(targetCity.toLowerCase())) {
      suppressionSummary['different_city'] = (suppressionSummary['different_city'] ?? 0) + 1;
      suppressedDonors.add({
        'id': d['id'],
        'name': d['full_name'],
        'blood_group': d['blood_group'],
        'city': dCity,
        'distance_km': double.parse(distKm.toStringAsFixed(1)),
        'reason': 'Different city ($dCity vs $targetCity)',
      });
      continue;
    }

    if (distKm > radiusKm) {
      suppressionSummary['outside_radius'] = (suppressionSummary['outside_radius'] ?? 0) + 1;
      suppressedDonors.add({
        'id': d['id'],
        'name': d['full_name'],
        'blood_group': d['blood_group'],
        'city': dCity,
        'distance_km': double.parse(distKm.toStringAsFixed(1)),
        'reason': 'Outside target radius (${distKm.toStringAsFixed(1)} km > ${radiusKm.toStringAsFixed(1)} km)',
      });
      continue;
    }

    if (respectTravelCap && distKm > maxRad) {
      suppressionSummary['exceeds_travel_cap'] = (suppressionSummary['exceeds_travel_cap'] ?? 0) + 1;
      suppressedDonors.add({
        'id': d['id'],
        'name': d['full_name'],
        'blood_group': d['blood_group'],
        'city': dCity,
        'distance_km': double.parse(distKm.toStringAsFixed(1)),
        'reason': 'Exceeds donor travel limit (${maxRad.toInt()} km < ${distKm.toStringAsFixed(1)} km)',
      });
      continue;
    }

    areaBreakdown[dArea] = (areaBreakdown[dArea] ?? 0) + 1;
    eligible.add({
      'id': d['id'],
      'name': d['full_name'],
      'blood_group': d['blood_group'],
      'distance_km': double.parse(distKm.toStringAsFixed(1)),
      'city': dCity,
      'area': dArea,
      'travel_radius_km': maxRad,
    });
  }

  final unitRate = channel == 'sms' ? 0.28 : 0.85;
  final totalCost = double.parse((eligible.length * unitRate).toStringAsFixed(2));

  return {
    'camp_id': campId,
    'venue_name': venueName,
    'eligible_count': eligible.length,
    'suppressed_count': suppressedDonors.length,
    'target_city': targetCity,
    'center_lat': effectiveLat,
    'center_lng': effectiveLng,
    'radius_km': radiusKm,
    'unit_rate_inr': unitRate,
    'estimated_cost_inr': totalCost,
    'requires_approval': eligible.length > 200,
    'sample_donors': eligible,
    'suppressed_donors': suppressedDonors,
    'area_breakdown': areaBreakdown,
    'suppression_summary': suppressionSummary,
  };
}
