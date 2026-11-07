// ============================================================================
// BloodNorms | supabase_service_platform_extension.dart
// Platform stats, broadcasts, badges, check-in, and notifications extensions
// ============================================================================

import '../../features/admin_console/services/index.dart';
import '../../features/bank_console/services/index.dart';
import '../../features/donor/services/index.dart';
import '../models/donor_badge_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';
import 'supabase_service.dart';

extension SupabaseServicePlatformExtension on SupabaseService {
  // Platform & Master Kill Switch
  Future<Map<String, int>> getPlatformStats() =>
      AdminPlatformService().getPlatformStats();
  Future<bool> getKillSwitch() => AdminPlatformService().getKillSwitch();
  Future<bool> setKillSwitch(bool active) =>
      AdminPlatformService().setKillSwitch(active);
  Future<List<Map<String, dynamic>>> getRecentActivityLog() =>
      AdminPlatformService().getRecentActivityLog();

  // Regional Broadcast Engine
  Future<Map<String, dynamic>> previewBroadcastAudience({
    String? campId,
    String targetCity = 'All',
    double? centerLat,
    double? centerLng,
    double radiusKm = 10.0,
    bool respectTravelCap = true,
    String bloodGroup = 'All',
    String channel = 'whatsapp',
  }) =>
      AdminBroadcastService().previewBroadcastAudience(
        campId: campId,
        targetCity: targetCity,
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
        respectTravelCap: respectTravelCap,
        bloodGroup: bloodGroup,
        channel: channel,
      );

  Future<Map<String, dynamic>> broadcastRegionalMessage({
    required String title,
    required String message,
    required String broadcastType,
    String? campId,
    String targetCity = 'All',
    double? centerLat,
    double? centerLng,
    double radiusKm = 10.0,
    bool respectTravelCap = true,
    String? bloodGroupFilter,
    String? areaFilter,
    String channel = 'whatsapp',
    String? approvalId,
  }) =>
      AdminBroadcastService().broadcastRegionalMessage(
        title: title,
        message: message,
        broadcastType: broadcastType,
        campId: campId,
        targetCity: targetCity,
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
        respectTravelCap: respectTravelCap,
        bloodGroupFilter: bloodGroupFilter,
        areaFilter: areaFilter,
        channel: channel,
        approvalId: approvalId,
      );

  // Milestone Badges & Camp Checkin
  Future<List<DonorBadgeModel>> getDonorBadges(
    String donorId, {
    int donationsCount = 0,
  }) =>
      DonorMilestoneService().getDonorBadges(donorId, donationsCount: donationsCount);

  Future<bool> awardDonorBadge({
    required String donorId,
    required String badgeCode,
    required String badgeName,
    required String description,
    String? certificateUrl,
  }) =>
      DonorMilestoneService().awardDonorBadge(
        donorId: donorId,
        badgeCode: badgeCode,
        badgeName: badgeName,
        description: description,
        certificateUrl: certificateUrl,
      );

  Future<Map<String, dynamic>> checkInCampAttendee({
    required String campId,
    String? donorId,
    String? phone,
    int units = 1,
  }) =>
      BankCampCheckinService().checkInCampAttendee(
        campId: campId,
        donorId: donorId,
        phone: phone,
        units: units,
      );

  Future<List<Map<String, dynamic>>> getCampAttendees(String campId) =>
      BankCampCheckinService().getCampAttendees(campId);

  // In-App Notifications
  Future<List<InAppNotificationModel>> getNotifications({
    String? recipientId,
    String? recipientRole,
    int limit = 30,
  }) =>
      NotificationService().getNotifications(
        recipientId: recipientId,
        recipientRole: recipientRole,
        limit: limit,
      );

  Future<bool> markNotificationAsRead(String notificationId) =>
      NotificationService().markNotificationAsRead(notificationId);

  Future<bool> sendInAppNotification({
    String? recipientId,
    required String recipientRole,
    required String title,
    required String body,
    required String category,
    Map<String, dynamic>? payload,
  }) =>
      NotificationService().sendInAppNotification(
        recipientId: recipientId,
        recipientRole: recipientRole,
        title: title,
        body: body,
        category: category,
        payload: payload,
      );
}

