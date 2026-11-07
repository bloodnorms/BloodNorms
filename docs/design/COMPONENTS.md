# BloodNorms — Component Catalog (docs/design/COMPONENTS.md)

This catalog details the shared UI component library located in `lib/shared/widgets/`.

---

## 1. `AppPillButton`

A tactile, fully rounded pill button with micro-animation feedback and minimum 44px tap target.

**Path:** `lib/shared/widgets/app_pill_button.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | Required | Button title in Grade-5 plain English |
| `icon` | `IconData?` | `null` | Optional icon rendered before label |
| `variant` | `AppPillButtonVariant` | `primary` | `primary`, `secondary`, `tonal`, `destructive`, `text` |
| `onPressed` | `VoidCallback?` | `null` | Click handler (null = disabled state) |
| `isLoading` | `bool` | `false` | Replaces label with spinner when true |
| `isFullWidth` | `bool` | `false` | Stretches button across parent width |

### Example Usage
```dart
AppPillButton(
  label: 'Dispatch broadcast',
  icon: Icons.send_rounded,
  variant: AppPillButtonVariant.primary,
  isLoading: isBroadcasting,
  onPressed: isBroadcasting ? null : onDispatch,
)
```

---

## 2. `AppStatCard`

A minimal, spacious metric card with headline number, label, soft circular icon, and hover lift.

**Path:** `lib/shared/widgets/app_stat_card.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `label` | `String` | Required | Small description label above number |
| `value` | `String` | Required | Large headline value (e.g. `1,420`, `₹482`) |
| `subtitle` / `trendText` | `String?` | `null` | Quiet status or percentage trend text below |
| `icon` | `IconData?` | `null` | Thin outline icon |
| `iconColor` | `Color?` | `primaryAction` | Icon glyph color |
| `iconBgColor` | `Color?` | `surfaceMuted` | Soft circular container background |
| `onTap` | `VoidCallback?` | `null` | Optional tap action |

### Example Usage
```dart
AppStatCard(
  label: 'Active donors',
  value: '${donorsList.length}',
  subtitle: '+8.4% today',
  icon: Icons.people_outline_rounded,
)
```

---

## 3. `AppSearchField`

A pill-shaped search input field with search prefix icon and clear button.

**Path:** `lib/shared/widgets/app_search_field.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `hintText` | `String` | `'Search...'` | Placeholder prompt |
| `controller` | `TextEditingController?`| `null` | Text editing controller |
| `onChanged` | `ValueChanged<String>?` | `null` | Live search query callback |
| `onClear` | `VoidCallback?` | `null` | Clear button callback |

### Example Usage
```dart
AppSearchField(
  hintText: 'Search donors by name or blood group...',
  onChanged: (query) => setState(() => _searchQuery = query),
)
```

---

## 4. `AppPageHeader`

A unified page header composing breadcrumb, headline title, friendly description, and a single primary action pill.

**Path:** `lib/shared/widgets/app_page_header.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | Required | View title (Headline 28px) |
| `description` | `String?` | `null` | Friendly explanation sentence |
| `actionLabel` | `String?` | `null` | Text for the primary action button |
| `actionIcon` | `IconData?` | `null` | Icon for the primary action button |
| `onAction` | `VoidCallback?` | `null` | Action button click handler |

---

## 5. `AppEmptyState`

A calm, friendly zero-data state with soft tinted circle icon, 1 explanatory sentence, and optional action pill.

**Path:** `lib/shared/widgets/app_empty_state.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `icon` | `IconData` | Required | Outline icon |
| `title` | `String` | Required | Positive title (e.g. `No active emergencies`) |
| `description` | `String` | Required | Calm 1-sentence explanation |
| `actionLabel` | `String?` | `null` | Optional recovery action button label |
| `onAction` | `VoidCallback?` | `null` | Action button click handler |

---

## 6. `AppErrorState`

An empathetic error card in plain words with a retry action button.

**Path:** `lib/shared/widgets/app_error_state.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `title` | `String` | `'Something went wrong'` | Friendly error headline |
| `message` | `String` | Required | Plain language error explanation |
| `recoveryAction` | `String?` | `null` | Suggestion on what to do |
| `onRetry` | `VoidCallback?` | `null` | Retry callback |

---

## 7. `SegmentedPicker<T>`

A sliding segmented control pill with soft track and elevated white active indicator.

**Path:** `lib/shared/widgets/segmented_picker.dart`

### Props & Parameters
| Property | Type | Default | Description |
|---|---|---|---|
| `items` | `List<SegmentItem<T>>` | Required | List of segment items (value, label, icon) |
| `selectedValue` | `T` | Required | Currently active selection |
| `onValueChanged` | `ValueChanged<T>` | Required | Selection change handler |

