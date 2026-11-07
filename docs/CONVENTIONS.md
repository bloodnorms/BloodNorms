# BloodNorms — Engineering & Architectural Conventions

## 1. Golden Architectural Rules

1. **Behavior-Preserving Only:** Any structural refactoring must preserve exact user-facing flows, routes, layout, visual hierarchy, and API contracts.
2. **One Main Responsibility Per File:** Target 50–150 lines per file; hard limit of 200 lines for components, services, and widgets (excluding generated code and timestamped SQL migrations).
3. **No Vendor Brand Names in Domain Code:** All classes, functions, files, and types must describe our blood banking and emergency donation domain, never imitating third-party brand names.
4. **Zero Untyped Dynamic Code:** Avoid `dynamic` method calls; declare return types and parameter types explicitly.

---

## 2. Directory Layout & Layer Boundaries

```
lib/
├─ app/                 # Application bootstrap, routing, global providers
├─ features/            # Feature domains (requester, donor, bank_console, admin_console)
│  └─ <feature>/
│     ├─ screens/       # Thin screen wrappers (composition only, no raw SQL/API calls)
│     ├─ widgets/       # UI components private to this feature
│     ├─ providers/     # State management (Riverpod / ChangeNotifier)
│     ├─ services/      # Domain-specific backend calls
│     └─ index.dart     # Public barrel for the feature
└─ shared/              # Reusable code used across 2+ features
   ├─ constants/        # Central application rules, bounds, and constants
   ├─ i18n/             # Trilingual localizations (EN, TE, HI)
   ├─ models/           # Domain data models (JSON deserialization)
   ├─ services/         # Cross-cutting clients (Supabase, Location, Messaging)
   ├─ theme/            # BrandColors, BrandTypography, AppTheme
   └─ widgets/          # Tactile UI components (ActionButton, BloodGroupTile, etc.)
```

### Dependency Rules:
- `shared/` NEVER imports from `features/`.
- Features import from other features ONLY via their public `index.dart`.
- Screen files are thin: no direct raw network fetches or state mutation algorithms inside build methods.

---

## 3. Naming Conventions

| Entity | Convention | Example |
|---|---|---|
| File names | `snake_case.dart` | `blood_group_tile.dart` |
| Folder names | `snake_case` | `bank_console/` |
| Widget classes | `PascalCase` | `ActionButton`, `QuantityStepper` |
| Hooks & helpers | `camelCase` / `useXxx` | `formatDistanceKm`, `useCallHistory` |
| Models | `PascalCaseModel` | `BloodBankModel`, `CampModel` |
| Constants | `UPPER_SNAKE_CASE` or `camelCase` | `BrandColors.red`, `AppConstants.pilotCity` |
| Enums | `PascalCase` | `BloodGroup`, `RequestUrgencyLevel` |

---

## 4. Documentation Standards

1. **Header Comment:** Every file begins with a concise 3-line comment describing its purpose, design system connection, and relationship to other modules.
2. **Public API Documentation:** Every exported class, public method, and custom widget constructor carries a `///` doc comment documenting parameters, edge cases, and side effects.
3. **Explain the WHY:** Comments clarify clinical rules, non-obvious mathematical formulas (e.g. Haversine distance, cooling periods), and privacy constraints.

---

## 5. Security & Privacy Rules

- **Zero Secrets in Frontend:** The client build (`assets/.env`) must NEVER contain `SUPABASE_SERVICE_ROLE_KEY`, `WHATSAPP_ACCESS_TOKEN`, or `GEMINI_API_KEY`.
- **Health Question Protection:** Never query or display raw donor medical questionnaire responses.
- **Audio Protection:** Never log, store, or serialize caller audio streams or conversational speech transcripts.
- **Audit Logs:** Never execute `UPDATE` or `DELETE` on the `audit_logs` table.
