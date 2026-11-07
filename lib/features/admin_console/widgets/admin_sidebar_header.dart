// ============================================================================
// BloodNorms | admin_sidebar_header.dart
// Admin Sidebar Top Brand Header & ⌘K Search Pill
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class AdminSidebarHeader extends StatelessWidget {
  final bool isSidebarCompact;
  final VoidCallback onToggleCompact;

  const AdminSidebarHeader({
    super.key,
    required this.isSidebarCompact,
    required this.onToggleCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE52E2E), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44E52E2E),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                ),
              ),
              if (!isSidebarCompact) ...[
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BloodNorms OS',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'admin.bloodnorms.org',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onToggleCompact,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.unfold_more_rounded,
                        color: Color(0xFF9CA3AF), size: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isSidebarCompact)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C23),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF282B37)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, size: 15, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search actions...  ⌘K',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
