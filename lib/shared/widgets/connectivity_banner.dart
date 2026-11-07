// ============================================================================
// BloodNorms | connectivity_banner.dart
// Top-of-screen tactile Duolingo offline & reconnect banner
// Non-intrusive, auto-retrying, Cardinal Red (#E52E2E), Universal Green for sync
// Strict Rules: Arial font only, FontWeight.normal & FontWeight.bold only.
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isOffline = false;
  bool _justReconnected = false;
  bool _isChecking = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) => _checkConnection());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;
    _isChecking = true;

    bool isOnline = true;
    try {
      final uri = Uri.parse('${AppConstants.defaultSupabaseUrl}/rest/v1/');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      // Any response code (even 401/404) means network route to Supabase server is alive!
      isOnline = res.statusCode > 0;
    } catch (_) {
      isOnline = false;
    }

    if (mounted) {
      if (!isOnline && !_isOffline) {
        setState(() {
          _isOffline = true;
          _justReconnected = false;
        });
      } else if (isOnline && _isOffline) {
        setState(() {
          _isOffline = false;
          _justReconnected = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _justReconnected = false);
        });
      }
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          Material(
            color: BrandColors.red,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: BrandColors.redShadow, width: 2.0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Offline Mode · Changes will sync when reconnected',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _checkConnection,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'RETRY',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_justReconnected)
          Material(
            color: BrandColors.green,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: BrandColors.greenShadow, width: 2.0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_done_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Back Online · Realtime connection restored',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

