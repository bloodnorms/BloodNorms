# How to Write Tests for BloodNorms (HOW_TO_WRITE_TESTS.md)

This practical guide is for engineers and AI agents contributing tests to BloodNorms. Follow these patterns to ensure consistency, fast execution, and zero production side-effects.

---

## 1. Directory Structure

```
test/                                   # Flutter client test suites
├─ admin_am12_security_audit_test.dart  # Security and DPDP compliance
├─ admin_am1_test.dart                  # Four-eyes governance and elevation
├─ blood_group_test.dart                # Medical compatibility rules
├─ edge_functions_contract_test.dart    # Supabase Edge Functions contracts
├─ database_rls_matrix_test.dart        # Database security matrix
└─ ...
voice-gateway/tests/                    # Node.js Voice Gateway test suites
├─ http-server.test.ts                  # HTTP & WebSocket upgrade tests
├─ call-session.test.ts                 # Session state machine tests
└─ logger.test.ts                       # PII redaction tests
tests/
├─ e2e/                                 # Playwright browser end-to-end tests
└─ load/                                # k6 / Node load-testing scripts
```

---

## 2. Writing a Flutter Unit or Widget Test

1. **Imports:** Use package imports or relative imports cleanly.
2. **Setup:** Use `setUp` and `tearDown` to reset shared singletons (e.g., `SupabaseService.mockInstance`).
3. **Domain Vocabulary:** Test names must describe user emergency scenarios, clinical rules, or security boundaries.

```dart
// Example: Testing blood compatibility
import 'package:flutter_test/flutter_test.dart';
import 'package:bloodnorms/shared/models/blood_group_model.dart';

void main() {
  group('BloodGroup Compatibility Suite', () {
    test('O negative can donate to all blood groups', () {
      final oNeg = BloodGroup.oNegative;
      for (final recipient in BloodGroup.values) {
        expect(oNeg.canDonateTo(recipient), isTrue,
            reason: 'O- must be universally compatible as red donor');
      }
    });
  });
}
```

---

## 3. Writing a Voice Gateway Test (TypeScript)

The Voice Gateway tests run natively using Node.js test runner (`node:test` and `node:assert`).

```typescript
// Example: Testing WebSocket upgrade rejection
import test from "node:test";
import assert from "node:assert/strict";
import http from "node:http";
import WebSocket from "ws";
import { GatewayServer } from "../src/server/http-server.js";

test("Rejects unauthenticated WebSocket upgrade", async () => {
  const server = new GatewayServer();
  await new Promise<void>((resolve) => server.listen(8081, resolve));

  await assert.rejects(
    new Promise((resolve, reject) => {
      const ws = new WebSocket("ws://localhost:8081/twilio/stream");
      ws.on("open", resolve);
      ws.on("error", reject);
    })
  );

  server.close();
});
```

---

## 4. Writing an Edge Function Contract Test

Edge Functions provide typed JSON responses to Twilio and Meta webhooks. Contract tests ensure their shapes never break:

```dart
test('Twilio Voice webhook generates valid TwiML Connect Stream', () {
  final twimlResponse = generateTwilioVoiceTwiML(
    streamUrl: 'wss://voice.bloodnorms.org/twilio/stream',
    voiceMode: 'ai',
  );
  expect(twimlResponse, contains('<Connect>'));
  expect(twimlResponse, contains('<Stream url="wss://voice.bloodnorms.org/twilio/stream"'));
});
```

---

## 5. Golden Rules for Tests

1. **Never use live credentials:** Always pass dummy or mock tokens (`test_secret`).
2. **Keep tests under 200 lines:** If a test suite exceeds 200 lines, split into focused sub-suites (e.g. `auth_test.dart`, `lifecycle_test.dart`).
3. **No flakiness:** Never rely on wall-clock timers (`Future.delayed` or `setTimeout`) without reasonable bounds or event callbacks.
4. **Clean up after yourself:** Reset mock databases, close active WebSockets, and stop HTTP servers in `tearDown` or `afterEach`.
