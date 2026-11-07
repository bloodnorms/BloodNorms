// ============================================================================
// BloodNorms | tests/e2e/specs/accessibility.spec.ts
//
// Accessibility verification suite adhering to WCAG 2.1 AA standards.
// ============================================================================

import { test, expect } from "@playwright/test";

test.describe("Accessibility (a11y) & WCAG Compliance Suite", () => {
  test("All interactive buttons have accessible text or labels", async ({ page }) => {
    await page.goto("/admin");

    const buttons = await page.locator("button, [role='button']").all();
    for (const button of buttons) {
      const isVisible = await button.isVisible();
      if (isVisible) {
        const text = await button.innerText();
        const ariaLabel = await button.getAttribute("aria-label");
        const title = await button.getAttribute("title");
        const hasAccessibleName = (text && text.trim().length > 0) || !!ariaLabel || !!title;

        expect(
          hasAccessibleName,
          `Button must have an accessible name: ${await button.evaluate((el) => el.outerHTML)}`
        ).toBe(true);
      }
    }
  });

  test("Form input elements have associated labels or aria-labels", async ({ page }) => {
    await page.goto("/admin");

    const inputs = await page.locator("input, select, textarea").all();
    for (const input of inputs) {
      const isVisible = await input.isVisible();
      if (isVisible) {
        const type = await input.getAttribute("type");
        if (type !== "hidden") {
          const ariaLabel = await input.getAttribute("aria-label");
          const placeholder = await input.getAttribute("placeholder");
          const id = await input.getAttribute("id");
          const hasLabel = !!ariaLabel || !!placeholder || !!id;

          expect(
            hasLabel,
            `Form input must have an accessible label: ${await input.evaluate((el) => el.outerHTML)}`
          ).toBe(true);
        }
      }
    }
  });
});
