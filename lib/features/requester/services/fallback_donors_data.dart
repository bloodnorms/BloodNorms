// ============================================================================
// BloodNorms | fallback_donors_data.dart
// Resilient default donor contacts for preview, simulation, and offline modes
// ============================================================================

import '../../../shared/models/donor_card_model.dart';

List<DonorCardModel> getFallbackDonors({
  required String bloodGroup,
  required double centerLat,
  required double centerLng,
}) {
  return [
    DonorCardModel(
      id: 'donor-resp-1',
      firstName: 'Anil Kumar',
      bloodGroup: bloodGroup,
      distanceBand: '< 1.2 km',
      etaMinutes: 15,
      status: 'accepted',
      isStandby: false,
      phoneRevealed: true,
      phone: '+919848012345',
      donationCode: 'BN-4821',
      latitude: centerLat + 0.0035,
      longitude: centerLng + 0.0030,
    ),
    DonorCardModel(
      id: 'donor-resp-2',
      firstName: 'Suresh Varma',
      bloodGroup: bloodGroup,
      distanceBand: '< 2.5 km',
      etaMinutes: 25,
      status: 'accepted',
      isStandby: false,
      phoneRevealed: true,
      phone: '+919848054321',
      donationCode: 'BN-7932',
      latitude: centerLat - 0.0045,
      longitude: centerLng - 0.0040,
    ),
    DonorCardModel(
      id: 'donor-resp-3',
      firstName: 'Ramesh Babu',
      bloodGroup: bloodGroup,
      distanceBand: '< 3.8 km',
      etaMinutes: 35,
      status: 'standby',
      isStandby: true,
      phoneRevealed: true,
      phone: '+919848098765',
      donationCode: 'BN-1156',
      latitude: centerLat + 0.0080,
      longitude: centerLng + 0.0075,
    ),
  ];
}

