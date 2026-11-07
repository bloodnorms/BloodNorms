// ============================================================================
// BloodNorms | app/providers.dart
//
// Root-level Riverpod providers for global application state.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/requester/providers/request_flow_provider.dart';

/// Central Riverpod provider for the Requester wizard state flow.
final requestFlowProvider = ChangeNotifierProvider<RequestFlowNotifier>((ref) {
  return RequestFlowNotifier();
});
