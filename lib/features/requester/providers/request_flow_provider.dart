// ============================================================================
// BloodNorms | request_flow_provider.dart
// State management for Requester wizard flow
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/blood_groups.dart';

class RequestFlowState {
  final BloodGroup? bloodGroup;
  final int units;
  final RequestUrgencyLevel urgency;
  final BloodComponentType component;
  final double lat;
  final double lng;
  final String placeLabel;
  final String hospitalName;
  final String hospitalArea;
  final String patientFirstName;
  final int? patientAge;
  final String requesterName;
  final String requesterPhone;
  final bool allowCompatible;
  final String note;
  final String? activeRequestId;

  RequestFlowState({
    this.bloodGroup,
    this.units = 1,
    this.urgency = RequestUrgencyLevel.now,
    this.component = BloodComponentType.wholeBlood,
    this.lat = AppConstants.defaultLat,
    this.lng = AppConstants.defaultLng,
    this.placeLabel = 'Rajahmundry, Andhra Pradesh',
    this.hospitalName = '',
    this.hospitalArea = '',
    this.patientFirstName = '',
    this.patientAge,
    this.requesterName = 'Family',
    this.requesterPhone = '',
    this.allowCompatible = false,
    this.note = '',
    this.activeRequestId,
  });

  RequestFlowState copyWith({
    BloodGroup? bloodGroup,
    int? units,
    RequestUrgencyLevel? urgency,
    BloodComponentType? component,
    double? lat,
    double? lng,
    String? placeLabel,
    String? hospitalName,
    String? hospitalArea,
    String? patientFirstName,
    int? patientAge,
    String? requesterName,
    String? requesterPhone,
    bool? allowCompatible,
    String? note,
    String? activeRequestId,
  }) {
    return RequestFlowState(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      units: units ?? this.units,
      urgency: urgency ?? this.urgency,
      component: component ?? this.component,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      placeLabel: placeLabel ?? this.placeLabel,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalArea: hospitalArea ?? this.hospitalArea,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientAge: patientAge ?? this.patientAge,
      requesterName: requesterName ?? this.requesterName,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      allowCompatible: allowCompatible ?? this.allowCompatible,
      note: note ?? this.note,
      activeRequestId: activeRequestId ?? this.activeRequestId,
    );
  }
}

class RequestFlowNotifier extends ChangeNotifier {
  RequestFlowState _state = RequestFlowState();
  RequestFlowState get state => _state;

  void setBloodGroup(BloodGroup group) {
    _state = _state.copyWith(bloodGroup: group);
    notifyListeners();
  }

  void setUnits(int units) {
    _state = _state.copyWith(units: units);
    notifyListeners();
  }

  void setUrgency(RequestUrgencyLevel urgency) {
    _state = _state.copyWith(urgency: urgency);
    notifyListeners();
  }

  void setComponent(BloodComponentType component) {
    _state = _state.copyWith(component: component);
    notifyListeners();
  }

  void setLocation({required double lat, required double lng, required String label}) {
    _state = _state.copyWith(lat: lat, lng: lng, placeLabel: label);
    notifyListeners();
  }

  void setHospitalDetails({required String name, required String area}) {
    _state = _state.copyWith(hospitalName: name, hospitalArea: area);
    notifyListeners();
  }

  void setPatientDetails({required String firstName, int? age}) {
    _state = _state.copyWith(patientFirstName: firstName, patientAge: age);
    notifyListeners();
  }

  void setRequesterPhone(String phone) {
    _state = _state.copyWith(requesterPhone: phone);
    notifyListeners();
  }

  void setAllowCompatible(bool allow) {
    _state = _state.copyWith(allowCompatible: allow);
    notifyListeners();
  }

  void setNote(String note) {
    _state = _state.copyWith(note: note);
    notifyListeners();
  }

  void setActiveRequestId(String id) {
    _state = _state.copyWith(activeRequestId: id);
    notifyListeners();
  }

  void reset() {
    _state = RequestFlowState();
    notifyListeners();
  }
}

final globalRequestFlow = RequestFlowNotifier();

