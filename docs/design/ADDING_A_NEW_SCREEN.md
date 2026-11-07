# Adding a New Screen to BloodNorms (docs/design/ADDING_A_NEW_SCREEN.md)

Follow this step-by-step tutorial to add a new admin screen or workspace view while adhering strictly to the architecture, design tokens, and the 200-line constraint.

---

## 1. Where Does the Code Live?

- **Screen Container:** `lib/features/admin_console/screens/`
- **Feature View Widget:** `lib/features/admin_console/widgets/<view_name>_view.dart`
- **Sub-Widgets & Cards:** `lib/features/admin_console/widgets/<view_name>_<subwidget>.dart`
- **State Controller:** `lib/features/admin_console/controllers/`
- **API/Supabase Calls:** `lib/features/admin_console/services/`

---

## 2. Step-by-Step Implementation

### Step 2.1: Create the Feature View File
Create `lib/features/admin_console/widgets/<new_feature>_view.dart`:
- Must import `../../../shared/theme/brand_colors.dart` and `../../../shared/theme/brand_typography.dart`.
- Must import shared components: `../../../shared/widgets/app_pill_button.dart`.
- Must stay under 200 lines (target 50–150 lines).

```dart
import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class NewFeatureView extends StatelessWidget {
  final VoidCallback onExecute;

  const NewFeatureView({super.key, required this.onExecute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New feature title',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AppPillButton(
            label: 'Execute primary action',
            variant: AppPillButtonVariant.primary,
            onPressed: onExecute,
          ),
        ],
      ),
    );
  }
}
```

### Step 2.2: Register in Barrel Export
Export the new widget in `lib/features/admin_console/widgets/index.dart`:
```dart
export '<new_feature>_view.dart';
```

### Step 2.3: Register in Sub-Router
Add the route case in `admin_workspace_router.dart` (or the appropriate sub-router):
```dart
case 'new_feature':
  return NewFeatureView(onExecute: ...);
```

### Step 2.4: Register in Sidebar Navigation Tree
Add navigation entry in `lib/features/admin_console/widgets/admin_sidebar_navigation_tree.dart`:
```dart
{'id': 'new_feature', 'title': 'New Feature'},
```

### Step 2.5: Verify Quality Gates
Before concluding, always run:
```bash
flutter analyze
flutter test
```
Confirm zero errors, zero warnings, and all tests passing.

