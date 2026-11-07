// ============================================================================
// BloodNorms | app_router.dart
// GoRouter navigation and deep linking per TRD §7 & PRD REQ-W16
// Supports /b, /live/:id, /donor, /bank, /admin
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin_console/screens/admin_console_screen.dart';
import '../../features/bank_console/screens/bank_console_screen.dart';
import '../../features/donor/screens/donor_home_screen.dart';
import '../../features/donor/screens/donor_onboarding_screen.dart';
import '../../features/donor/screens/donor_ticket_screen.dart';
import '../../features/requester/screens/banks_list_screen.dart';
import '../../features/requester/screens/blood_group_screen.dart';
import '../../features/requester/screens/home_screen.dart';
import '../../features/requester/screens/live_tracking_screen.dart';
import '../../features/requester/screens/location_screen.dart';
import '../../features/requester/screens/public_banks_screen.dart';
import '../../features/requester/screens/request_details_screen.dart';
import '../../features/requester/screens/review_send_screen.dart';
import '../../features/requester/screens/units_urgency_screen.dart';

GoRouter createRouter({
  required ValueChanged<Locale> onLocaleChanged,
  required VoidCallback onToggleTheme,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Requester Journey
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(
          onLocaleChanged: onLocaleChanged,
          onToggleTheme: onToggleTheme,
        ),
      ),
      GoRoute(
        path: '/group',
        builder: (context, state) => const BloodGroupScreen(),
      ),
      GoRoute(
        path: '/units',
        builder: (context, state) => const UnitsUrgencyScreen(),
      ),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: '/banks',
        builder: (context, state) => const BanksListScreen(),
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) => const RequestDetailsScreen(),
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) => const ReviewSendScreen(),
      ),
      GoRoute(
        path: '/live/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'mock-live';
          return LiveTrackingScreen(requestId: id);
        },
      ),

      // 2. Public Banks Directory (/b)
      GoRoute(
        path: '/b',
        builder: (context, state) => const PublicBanksScreen(),
      ),

      // 3. Donor App
      GoRoute(
        path: '/donor',
        builder: (context, state) => const DonorHomeScreen(),
      ),
      GoRoute(
        path: '/donor/onboarding',
        builder: (context, state) => const DonorOnboardingScreen(),
      ),
      GoRoute(
        path: '/donor/ticket/:id',
        builder: (context, state) => const DonorTicketScreen(),
      ),

      // 4. Blood Bank Staff Console
      GoRoute(
        path: '/bank',
        builder: (context, state) => const BankConsoleScreen(),
      ),

      // 5. Admin Console
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminConsoleScreen(),
      ),
    ],
  );
}

