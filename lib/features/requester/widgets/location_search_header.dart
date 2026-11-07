// ============================================================================
// BloodNorms | location_search_header.dart
// Search bar and quick landmark chips for the location picker
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_text_field.dart';

class LocationSearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String hintText;
  final List<Map<String, dynamic>> quickLocations;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<Map<String, dynamic>> onSelectQuickLocation;

  const LocationSearchHeader({
    super.key,
    required this.searchController,
    required this.hintText,
    required this.quickLocations,
    required this.onSearchSubmitted,
    required this.onSelectQuickLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          AppTextField(
            controller: searchController,
            hintText: hintText,
            prefixIcon: Icons.search_rounded,
            suffix: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: BrandColors.red),
              onPressed: () => onSearchSubmitted(searchController.text),
            ),
            onChanged: (val) {
              if (val.length > 3) {
                onSearchSubmitted(val);
              }
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickLocations.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSelectQuickLocation(q),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: BrandColors.border, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: BrandColors.border,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me_rounded, size: 14, color: BrandColors.red),
                          const SizedBox(width: 6),
                          Text(
                            q['name'],
                            style: TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              color: BrandColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
