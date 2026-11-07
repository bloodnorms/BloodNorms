# BloodNorms — Tactile Design System & Standards (DESIGN_SYSTEM.md)

**Role:** Principal Design Systems Architect & UX Lead  
**Applicability:** Flutter Web, Android, iOS Client Applications  
**Version:** 1.0.0

---

## 1. Design Philosophy: Emergency Clarity & Tactile Feedback

BloodNorms is used by stressed citizens and healthcare workers during medical crises. The user interface must be:
1. **Instantly Legible:** Zero decorative noise, zero low-contrast text, clear visual hierarchy.
2. **Tactile & Physical:** Large tap targets (>= 48x48 dp) with physical depression feedback on click/press.
3. **Single Typography Token:** Strict Arial typography across all platforms for predictable line wrapping and multilingual rendering.

---

## 2. Color System & Contrast Ratios

All color tokens adhere to WCAG 2.1 AA contrast requirements (minimum 4.5:1 against surfaces):

| Token Name | Hex Code | Semantic Role | Contrast vs `#FFFFFF` |
|---|---|---|---|
| `BrandColors.red` | `#C62828` | Emergency action buttons, critical shortages, Cardinal Red branding | 5.9:1 (PASS) |
| `BrandColors.green` | `#2E7D32` | Availability indicators, positive confirmations, Universal Green | 4.6:1 (PASS) |
| `BrandColors.ink` | `#1A1A1A` | Primary typography, headers, icons | 16.1:1 (PASS) |
| `BrandColors.muted` | `#666666` | Secondary labels, timestamps, measurement units | 5.7:1 (PASS) |
| `BrandColors.surface` | `#F7F7F8` | Screen background, subtle card surface | 1.1:1 (Surface) |
| `BrandColors.border` | `#E0E0E0` | Card borders, divider lines | Structural |

---

## 3. Typography Hierarchy (Arial Only)

```
Heading 1 (H1)  - 28px / Bold (700)      - Screen Titles & Emergency Headers
Heading 2 (H2)  - 22px / SemiBold (600)  - Section Headers, KPI Metric Totals
Heading 3 (H3)  - 18px / Medium (500)    - Card Titles, Modal Headers
Body Primary    - 15px / Regular (400)   - Paragraphs, Input Labels
Body Muted      - 13px / Regular (400)   - Timestamps, Secondary Descriptions
Caption / Micro - 11px / SemiBold (600)  - Badges, Status Tags, Data Units
```

---

## 4. Tactile UI Components

1. **`HeroEmergencyButton` / `ActionButton`:**
   - Height: 54 dp minimum.
   - Background: `BrandColors.red`.
   - Text: 16px Bold White.
   - Ripple and depression animation on press.
2. **`BloodGroupTile`:**
   - 64x64 dp square tactile button.
   - Clear large glyph (`A+`, `O-`) with selected state border.
3. **`QuantityStepper`:**
   - Large `+` and `-` physical buttons (44x44 dp) flanking numeric counter.
4. **`DonorRadarCard`:**
   - Concentric pulse animation indicating live match expansion.

