# BloodNorms — UI & UX Design Guide (DESIGN.md)

Welcome to the BloodNorms design manual. All engineers and AI coding assistants must strictly adhere to the design rules, tokens, and UX principles described here to maintain architectural harmony and visual calm across the entire product.

---

## 1. The Core Design Vision

BloodNorms is designed for healthcare workers, blood coordinators, and emergency responders under extreme pressure. Every screen must feel:
1. **Clean, Calm, and Modern:** Inspired by the aesthetic clarity of Google's Stitch platform (`stitch.withgoogle.com`): minimal, spacious, soft, friendly, and light.
2. **"3-Year-Old Simple":** Any user should instantly spot the single primary action and understand what to do without reading instructions.
3. **Light Theme Only:** We build strictly in Light Mode (`color-scheme: light`). Never re-introduce dark mode toggles or dark color variants.

---

## 2. Design Tokens at a Glance

All design tokens are located in `lib/shared/theme/brand_colors.dart` and `lib/shared/theme/brand_typography.dart`. **Never hardcode hex colors or arbitrary pixel values in feature code.**

### 2.1 Colors
- **Background:** `BrandColors.background` (`#FFFFFF`)
- **Soft Surface:** `BrandColors.surfaceSoft` (`#F8F9FA`)
- **Muted Surface:** `BrandColors.surfaceMuted` (`#F1F3F4`)
- **Borders:** `BrandColors.borderSubtle` (`#E8EAED`), `BrandColors.borderStrong` (`#DADCE0`)
- **Primary Action:** `BrandColors.primaryAction` (Near-black `#1F1F1F`)
- **Accent:** `BrandColors.accent` (`#5B5BF0`), Tint `BrandColors.accentTint` (`#EEF0FF`)
- **Status Success:** `BrandColors.statusSuccess` (`#1E8E3E`), Tint `BrandColors.statusSuccessTint` (`#E6F4EA`)
- **Status Warning:** `BrandColors.statusWarning` (`#B06000`), Tint `BrandColors.statusWarningTint` (`#FEF7E0`)
- **Status Error:** `BrandColors.statusError` (`#D93025`), Tint `BrandColors.statusErrorTint` (`#FCE8E6`)
- **Text:** `BrandColors.textPrimary` (`#202124`), `BrandColors.textSecondary` (`#5F6368`), `BrandColors.textMuted` (`#9AA0A6`)

### 2.2 Geometry
- **Pill controls (buttons, badges, search):** `BrandColors.radiusPill` (`999.0`)
- **Cards & metric containers:** `BrandColors.radiusCard` (`16.0`)
- **Text inputs & dropdowns:** `BrandColors.radiusInput` (`12.0`)
- **Modals & bottom sheets:** `BrandColors.radiusDialog` (`24.0`)
- **Minimum touch target:** `BrandColors.minTouchTarget` (`44.0` px)

---

## 3. The 18 "3-Year-Old Simple" UX Rules

1. **One Screen, One Job:** Every screen or view has exactly one primary purpose.
2. **One Primary Action Pill:** Exactly one near-black `#1F1F1F` pill button per view. Secondary buttons must be outlined (`AppPillButtonVariant.secondary`) or tonal (`AppPillButtonVariant.tonal`).
3. **Pill Buttons for Everything Interactive:** Standardize on `AppPillButton` across all screens.
4. **>= 44px Tap Targets:** No button, toggle, or interactive element may have a touch area smaller than 44x44 dp.
5. **No Technical Jargon in UI:** Speak Grade-5 plain language ("Triage queue" not "Stalled async pipeline", "Connect centers" not "RPC federation").
6. **No "Superhero" or Whimsical Names:** Use clear domain names only (`Quick actions`, `Donors directory`, `Approvals queue`).
7. **Calm Color Usage:** Use color semantically to convey status only, never for random decorative backdrops.
8. **Stat Metric Cards:** Use `AppStatCard` for top-line numbers. Never create busy rainbow gradient cards.
9. **Search Fields:** Use `AppSearchField` with fully rounded pill styling, prefix search icon, and suffix clear button.
10. **Prompt-Style Composers:** Long text composers must feel like talking, not configuring. Single wide rounded card with chips below.
11. **Friendly Empty States:** Always show `AppEmptyState` with a soft circular icon, 1 clear title, 1 calm description, and a single action pill.
12. **Empathetic Error States:** Always show `AppErrorState` explaining what happened in plain words and providing a retry action pill.
13. **Comfortable Table Rows:** Data rows must have generous height (>= 48px), comfortable padding, and pill status tags.
14. **Progressive Disclosure:** Advanced settings or destructive options sit behind clean expandable sections or clear dialogs.
15. **Floating Pill Toasts:** Toast notifications float bottom-center in near-black `#1F1F1F` pill containers with 2-second timeout.
16. **Maker-Checker Governance:** High-risk actions automatically prompt clean Four-Eyes approval dialogs without crashing.
17. **Gentle Micro-Interactions:** Subtle scale animation (0.98) on button click; 2px hover lift on cards.
18. **Light Theme Strictness:** Hardcoded dark containers (`#121316`, `#1A1C23`) are banned. All surfaces use the light palette.

---

## 4. Banned Anti-Patterns

- **NEVER** use "google", "stitch", or other third-party brand names in code identifiers.
- **NEVER** hardcode hex values like `#E52E2E` or `#121316` directly in view files.
- **NEVER** exceed the 200-line file limit. Extract sub-widgets immediately if approaching 200 lines.
- **NEVER** place two primary black action pill buttons next to each other.
- **NEVER** introduce dark theme variants or toggles.
