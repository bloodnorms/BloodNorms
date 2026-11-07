// ============================================================================
// BloodNorms | admin_directory_sub_router.dart
// Sub-router for Camps, Banks, Donors, Hospitals, Shield & Community Partners
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/models/camp_model.dart';
import 'blood_banks_stock_view.dart';
import 'blood_camps_admin_view.dart';
import 'community_partners_view.dart';
import 'donors_registry_view.dart';
import 'hospitals_registry_view.dart';
import 'requester_shield_view.dart';

class AdminDirectorySubRouter {
  static Widget? maybeBuild({
    required String activePage,
    required List<CampModel> campsList,
    required List<BloodBankModel> banksList,
    required Map<String, int> stockMatrix,
    required List<Map<String, dynamic>> donorsList,
    required List<Map<String, dynamic>> hospitalsList,
    required List<Map<String, dynamic>> requestersList,
    required List<Map<String, dynamic>> partnersList,
    required void Function(String page) onNavigate,
    required void Function(CampModel camp) onCampSelectedForBroadcast,
    required void Function(CampModel newCamp) onCampCreated,
    required void Function(String group, int delta) onAdjustStock,
    required void Function(String donorId, String currentState) onToggleDonorPause,
    required void Function(String phone, bool currentBlocked) onToggleRequesterBlock,
    required void Function(String message) onShowToast,
  }) {
    switch (activePage) {
      case 'camps_list':
      case 'camps_create':
        return BloodCampsAdminView(
          subPage: activePage,
          campsList: campsList,
          banksList: banksList,
          onNavigateToCreate: () => onNavigate('camps_create'),
          onCampSelectedForBroadcast: onCampSelectedForBroadcast,
          onCampCreated: onCampCreated,
          onShowToast: onShowToast,
        );
      case 'banks_directory':
      case 'banks_stock':
        return BloodBanksStockView(
          subPage: activePage,
          banksList: banksList,
          stockMatrix: stockMatrix,
          onAdjustStock: onAdjustStock,
        );
      case 'donors_list':
      case 'donors_location':
        return DonorsRegistryView(
          subPage: activePage,
          donorsList: donorsList,
          onToggleDonorPause: onToggleDonorPause,
          onShowToast: onShowToast,
        );
      case 'hospitals_list':
        return HospitalsRegistryView(
          hospitalsList: hospitalsList,
        );
      case 'requester_shield':
        return RequesterShieldView(
          requestersList: requestersList,
          onToggleRequesterBlock: onToggleRequesterBlock,
        );
      case 'community_partners':
        return CommunityPartnersView(
          partnersList: partnersList,
        );
      default:
        return null;
    }
  }
}
