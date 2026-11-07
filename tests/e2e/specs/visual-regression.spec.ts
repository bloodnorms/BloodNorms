// ============================================================================
// BloodNorms | tests/e2e/specs/visual-regression.spec.ts
//
// Visual regression snapshot baseline suite for critical operational views.
// ============================================================================

import { test, expect } from "@playwright/test";

test.describe("Visual Regression Baseline Suite", () => {
  test("Executive Cockpit matches visual snapshot baseline", async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto("/admin");
    await page.waitForLoadState("networkidle");

    // Mask dynamic clock / timestamp elements to avoid false diffs
    await page.evaluate(() => {
      document.querySelectorAll("[data-testid='live-timestamp']").forEach((el) => {
        (el as HTMLElement).style.visibility = "hidden";
      });
    });

    await expect(page).toHaveScreenshot("admin-cockpit-baseline.png", {
      maxDiffPixelRatio: 0.05,
      animations: "disabled",
    });
  });

  test("Emergency Broadcast Composer matches visual snapshot baseline", async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 800 });
    await page.goto("/admin#broadcasts");
    await page.waitForLoadState("networkidle");

    await expect(page).toHaveScreenshot("broadcast-composer-baseline.png", {
      maxDiffPixelRatio: 0.05,
      animations: "disabled",
    });
  });
});
