# Contributing to BloodNorms

Thank you for helping build BloodNorms — open-source, emergency blood infrastructure for India.

---

## 1. Branch Strategy & Conventional Commits

We follow the **Conventional Commits** specification. Commit messages must be structured as:

```
<type>(<scope>): <subject>
```

### Commit Types:
- `feat`: A new user-facing feature or API capability
- `fix`: A bug fix
- `refactor`: Code reorganization that does NOT alter user-facing behavior or API contracts
- `perf`: A code change that improves performance
- `test`: Adding or updating automated tests
- `docs`: Documentation updates only
- `chore`: Maintenance, dependencies, or tooling

### Examples:
- `refactor(shared): extract models into shared/models directory`
- `feat(bank): add automated deferral reason sheet`
- `fix(location): clamp radius slider to 100km maximum`

---

## 2. Pull Request Checklist

Before submitting a Pull Request, verify all quality gates:

- [ ] `flutter analyze` passes with 0 errors and 0 warnings.
- [ ] `flutter test` passes all 77 automated test suites.
- [ ] Any touched TypeScript code (`voice-gateway/`) compiles with `npm run build`.
- [ ] No secrets, live tokens, or service role keys are added to git.
- [ ] File size limit of ~200 lines adhered to.
- [ ] New UI widgets use `BrandColors` and `BrandTypography` tokens.
- [ ] New user-facing strings adhere to the strict 28-character budget (§14.3).

---

## 3. Step-by-Step Recipes

### Recipe A: Adding a New Screen
1. Create screen file: `lib/features/<feature>/screens/<screen_name>_screen.dart`.
2. Make it thin: instantiate a `Scaffold`, use `ScreenHeader` as `appBar`, compose feature-specific widgets from `lib/features/<feature>/widgets/`.
3. Never put raw Supabase RPC or HTTP queries in the screen's build method; call methods on `lib/features/<feature>/services/` or watch Riverpod providers.
4. Register the route in `lib/app/router.dart`.

### Recipe B: Adding a New Shared UI Component
1. Create `lib/shared/widgets/<widget_name>.dart`.
2. Use `BrandColors` and `BrandTypography` exclusively.
3. Add physical 3D pushable bevel styling using `BrandColors.bevelHeight` (4.0).
4. Export the component in `lib/shared/widgets/index.dart`.

### Recipe C: Adding a New Speech/Voice Provider
1. Navigate to `voice-gateway/src/providers/`.
2. Create `<provider-name>-adapter.ts` implementing the `SpeechProvider` interface from `types/index.ts`.
3. Encapsulate all vendor-specific protocols so the rest of the gateway remains vendor-neutral.
