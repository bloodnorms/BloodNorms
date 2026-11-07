// ============================================================================
// BloodNorms | tests/e2e/fixtures/page-objects/admin-console-page.ts
//
// Page Object Model for the BloodNorms Executive Operations Center (/admin).
// ============================================================================

import type { Page, Locator } from "@playwright/test";
import { expect } from "@playwright/test";

export class AdminConsolePage {
  readonly page: Page;
  readonly sidebar: Locator;
  readonly cockpitHeader: Locator;
  readonly maintenanceBanner: Locator;
  readonly kpiCards: Locator;

  constructor(page: Page) {
    this.page = page;
    this.sidebar = page.locator('[data-testid="admin-sidebar"]');
    this.cockpitHeader = page.locator('text=Executive Operations Center');
    this.maintenanceBanner = page.locator('[data-testid="maintenance-banner"]');
    this.kpiCards = page.locator('[data-testid="kpi-card"]');
  }

  async goto(): Promise<void> {
    await this.page.goto("/admin");
    await this.page.waitForLoadState("networkidle");
  }

  async navigateToTab(tabName: string): Promise<void> {
    const tabLocator = this.page.locator(`text=${tabName}`);
    await tabLocator.first().click();
    await this.page.waitForLoadState("networkidle");
  }

  async expectCleanConsole(collectedErrors: string[]): Promise<void> {
    expect(collectedErrors, "Expected zero uncaught browser console errors").toEqual([]);
  }

  async verifyKpisVisible(): Promise<void> {
    await expect(this.kpiCards.first()).toBeVisible();
  }
}
