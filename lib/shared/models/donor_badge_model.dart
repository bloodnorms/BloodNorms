// ============================================================================
// BloodNorms | shared/models/donor_badge_model.dart
//
// Data model for a gamification badge earned by a donor after milestones
// (e.g., first donation, 5 donations). Used by DonorHomeScreen and
// AdminConsoleScreen donors registry.
// Deserialized from the `donor_badges` Supabase table.
// ============================================================================

/// A milestone badge awarded to a donor for reaching a donation target.
class DonorBadgeModel {
  final String id;
  final String donorId;

  /// Unique badge identifier, e.g. 'bronze_hero', 'silver_lifesaver'.
  final String badgeCode;

  final String badgeName;
  final String description;
  final DateTime unlockedAt;

  /// Optional URL to a shareable PDF certificate.
  final String? certificateUrl;

  final bool isUnlocked;

  /// Number of donations required to earn this badge.
  final int requiredDonations;

  /// Emoji icon displayed in the UI.
  final String icon;

  const DonorBadgeModel({
    required this.id,
    required this.donorId,
    required this.badgeCode,
    required this.badgeName,
    required this.description,
    required this.unlockedAt,
    this.certificateUrl,
    this.isUnlocked = true,
    this.requiredDonations = 1,
    this.icon = '🥉',
  });

  factory DonorBadgeModel.fromJson(Map<String, dynamic> json) {
    return DonorBadgeModel(
      id: json['id']?.toString() ?? '',
      donorId: json['donor_id']?.toString() ?? '',
      badgeCode: json['badge_code']?.toString() ?? 'bronze_hero',
      badgeName: json['badge_name']?.toString() ?? 'Milestone Badge',
      description: json['description']?.toString() ?? '',
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      certificateUrl: json['certificate_url']?.toString(),
      isUnlocked: json['is_unlocked'] == true || json['unlocked_at'] != null,
      requiredDonations: (json['required_donations'] as num?)?.toInt() ?? 1,
      icon: json['icon']?.toString() ?? '🥉',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_id': donorId,
      'badge_code': badgeCode,
      'badge_name': badgeName,
      'description': description,
      'unlocked_at': unlockedAt.toIso8601String(),
      'certificate_url': certificateUrl,
      'is_unlocked': isUnlocked,
      'required_donations': requiredDonations,
      'icon': icon,
    };
  }
}

