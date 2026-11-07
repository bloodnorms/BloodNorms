# BloodNorms — Minimal Light Design System Specification

**Role:** Principal Product Designer & Design Systems Architect  
**Applicability:** Flutter Web, Desktop, iOS, Android  
**Version:** 2.0.0 (Minimal Light Theme Architecture)

---

## 1. Design Philosophy: Calm, Minimal & Tactile Simplicity

The BloodNorms console operates during high-stress emergency matching and medical logistics. The design direction draws inspiration from Google's Stitch design language (`stitch.withgoogle.com`):
- **Light Theme Only:** A single, pure, high-contrast light palette (`#FFFFFF` background, `#F8F9FA` soft surfaces, `#E8EAED` subtle borders). Dark mode and dark variants are eliminated to reduce cognitive strain and eliminate UI bifurcation.
- **Pill Geometry:** Fully rounded pill-shaped controls (`radiusPill = 999.0`) for all primary actions, search bars, segmented pickers, and status tags.
- **Calm, High-Confidence Surfaces:** Generous padding (16–24px), soft rounded cards (`radiusCard = 16.0`), minimal 1px neutral borders, and crisp near-black primary actions (`#1F1F1F`) paired with blue-violet accent highlights (`#5B5BF0`).
- **3-Year-Old Simple UX:** "One screen, one job." Exactly one primary action pill per view. Every button is >= 44px tap target. Zero confusing technical jargon.

---

## 2. Core Color Tokens

All tokens are defined in `lib/shared/theme/brand_colors.dart` and pass WCAG 2.1 AA contrast requirements:

| Token Name | Hex Value | Role | Usage |
|---|---|---|---|
| `BrandColors.background` | `#FFFFFF` | Canvas & Card Base | Primary surface for cards, dialogs, sheets |
| `BrandColors.surfaceSoft` | `#F8F9FA` | Soft Container | Sidebar, grouped rows, table header |
| `BrandColors.surfaceMuted` | `#F1F3F4` | Muted Surface | Segmented picker track, pill backgrounds |
| `BrandColors.borderSubtle` | `#E8EAED` | 1px Neutral Border | Subtle card borders, dividers, outlines |
| `BrandColors.borderStrong` | `#DADCE0` | Strong Border | Hover states, active borders |
| `BrandColors.primaryAction` | `#1F1F1F` | Near-Black Pill | Primary button background |
| `BrandColors.accent` | `#5B5BF0` | Blue-Violet Accent | Interactive links, active nav item, icons |
| `BrandColors.accentTint` | `#EEF0FF` | Accent Tint | Active nav pill background, category badges |
| `BrandColors.statusSuccess` | `#1E8E3E` | Calm Green | Confirmed, connected, verified statuses |
| `BrandColors.statusSuccessTint`| `#E6F4EA` | Green Tint | Success badge background |
| `BrandColors.statusWarning` | `#B06000` | Warm Amber | Pending verification, quota warnings |
| `BrandColors.statusWarningTint`| `#FEF7E0` | Amber Tint | Warning badge background |
| `BrandColors.statusError` | `#D93025` | Signal Red | Urgent shortages, cancellations, errors |
| `BrandColors.statusErrorTint` | `#FCE8E6` | Red Tint | Emergency badge background |
| `BrandColors.textPrimary` | `#202124` | Primary Text | Headings, labels, numbers (16:1 contrast) |
| `BrandColors.textSecondary` | `#5F6368` | Secondary Text | Subtitles, metadata, timestamps (5.7:1) |
| `BrandColors.textMuted` | `#9AA0A6` | Muted Text | Placeholder text, disabled labels |

---

## 3. Shape & Spatial Tokens

```dart
static const double radiusPill   = 999.0; // Buttons, search inputs, badges
static const double radiusCard   = 16.0;  // Standard cards, metric containers
static const double radiusInput  = 12.0;  // Form text inputs, dropdowns
static const double radiusDialog = 24.0;  // Modal dialogs, bottom sheets
static const double minTouchTarget = 44.0; // Minimum interactive tap target
```

---

## 4. Typography Scale

All typography uses geometric sans-serif (`Arial` with system fallbacks) defined in `lib/shared/theme/brand_typography.dart`:

| Style | Size | Weight | Tracking | Line Height | Usage |
|---|---|---|---|---|---|
| `display` | 40px | 600 (SemiBold) | -0.5 | 1.15 | Hero metric totals |
| `headline` | 28px | 600 (SemiBold) | -0.3 | 1.20 | View titles, main card numbers |
| `title` | 20px | 600 (SemiBold) | -0.2 | 1.25 | Section headers, modal titles |
| `bodyLarge` | 16px | 400 (Regular) | 0.0 | 1.40 | Form inputs, introductory text |
| `body` | 14px | 400 (Regular) | 0.0 | 1.45 | Default body copy, descriptions |
| `label` | 12px | 500 (Medium) | +0.1 | 1.30 | Pill tags, table columns, badges |
| `mono` | 13px | 400 (Regular) | 0.0 | 1.35 | Hashes, IDs, cryptographic watermarks |

---

## 5. Core Reusable Component Library

| Component | Location | Description |
|---|---|---|
| `AppPillButton` | `lib/shared/widgets/app_pill_button.dart` | Pill button with 5 variants (`primary`, `secondary`, `tonal`, `destructive`, `text`), scale micro-interaction (0.98), loading indicator, >= 44px tap target. |
| `AppStatCard` | `lib/shared/widgets/app_stat_card.dart` | Soft 16px card with 1px border, large headline metric, circular icon container, subtle trend text, and hover lift. |
| `AppSearchField` | `lib/shared/widgets/app_search_field.dart` | Fully rounded pill search input with search icon prefix and clear button suffix. |
| `AppPageHeader` | `lib/shared/widgets/app_page_header.dart` | Unified page title, friendly description sentence, and single primary action button top-right. |
| `AppEmptyState` | `lib/shared/widgets/app_empty_state.dart` | Soft-tinted circular icon, friendly plain-language explanation, and prominent action pill. |
| `AppErrorState` | `lib/shared/widgets/app_error_state.dart` | Soft error tint icon, plain words message, recovery advice, and retry pill button. |
| `SegmentedPicker` | `lib/shared/widgets/segmented_picker.dart` | Sliding pill segmented control with soft track and elevated white active pill indicator. |

---

## 6. Micro-Interactions & Motion

- **Button Press Feedback:** Quick scale animation (`0.98`) over 100ms with `Curves.easeInOut`.
- **Card Hover Elevation:** Hover lift (`translateY -2px`) over 150ms with subtle drop shadow `BrandColors.shadowCardHover`.
- **Segmented Picker Slide:** Pill sliding indicator duration 150ms with `Curves.easeOutCubic`.
