// ============================================================================
// BloodNorms | connectivity_banner.dart
// Top-of-screen offline & reconnect status banner
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
            color: BrandColors.statusError,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1), width: 1.0)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BrandColors.radiusPill)),
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
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.1), width: 1.0)),
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
