// ============================================================================
// BloodNorms | tests/e2e/specs/admin-navigation.spec.ts
//
// End-to-End navigation and regression test suite across admin modules.
// ============================================================================

import { test, expect } from "@playwright/test";
import { AdminConsolePage } from "../fixtures/page-objects/admin-console-page.js";

test.describe("Admin Console Navigation & Viewport Suite", () => {
  let consoleErrors: string[] = [];

  test.beforeEach(async ({ page }) => {
    consoleErrors = [];
    page.on("console", (msg) => {
      if (msg.type() === "error") {
        consoleErrors.push(msg.text());
      }
    });
    page.on("pageerror", (err) => {
      consoleErrors.push(err.message);
    });
  });

  test("Loads Admin Cockpit with zero browser console errors", async ({ page }) => {
    const admin = new AdminConsolePage(page);
    await admin.goto();
    await admin.expectCleanConsole(consoleErrors);
  });

  test("Allows navigating between sidebar tabs without unhandled exceptions", async ({ page }) => {
    const admin = new AdminConsolePage(page);
    await admin.goto();

    const tabsToVisit = [
      "Live Cockpit",
      "Emergency Broadcast",
      "Blood Camps",
      "Ledgers & Rates",
      "Audit Trail",
      "Feature Flags",
    ];

    for (const tab of tabsToVisit) {
      await admin.navigateToTab(tab);
      await admin.expectCleanConsole(consoleErrors);
    }
  });

  test("Maintains responsive layout on mobile viewport (375x667)", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    const admin = new AdminConsolePage(page);
    await admin.goto();
    await admin.expectCleanConsole(consoleErrors);
  });
});
