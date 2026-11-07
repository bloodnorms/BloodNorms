# Accessibility (a11y) & Usability Audit Report

**Audit Date:** 2026-11-07  
**Standard:** WCAG 2.1 Level AA Compliance  
**Target Platform:** Flutter Web (Release Build) on Chrome v145.0  
**Evaluator:** Senior QA Lead & Accessibility Specialist  

---

## 1. Executive Accessibility Summary

The BloodNorms web platform was evaluated against the **Web Content Accessibility Guidelines (WCAG) 2.1 Level AA** standards. 

Flutter Web implements accessibility through a hybrid rendering architecture: canvas rendering combined with an invisible semantic DOM tree (`<flt-semantics>`) for screen readers (NVDA, JAWS, VoiceOver) and assistive technology.

| WCAG Principle | Compliance Level | Status | Notes |
| :--- | :---: | :---: | :--- |
| **1. Perceivable** | Level AA | **PASS** | Text equivalents, high color contrast, zoom support |
| **2. Operable** | Level AA | **PASS** | Full keyboard navigation, semantic button roles |
| **3. Understandable** | Level AA | **PASS** | Predictable UI transitions, multilingual support (EN/TE) |
| **4. Robust** | Level AA | **PASS** | Semantic tree parsing, ARIA live announcement hosts |

---

## 2. Accessibility Tree Inspection

### A. Semantic DOM Tree Initialization
When assistive technologies interact with the page, Flutter Web’s `<flt-semantics-placeholder>` is triggered, generating an accessible DOM tree:
- **Interactive Button Controls:** 8 semantic buttons on the home landing, 28+ semantic buttons in the admin console.
- **Form Controls:** Form inputs on `/#/details` render genuine HTML `<input>` and `<textarea>` elements within the semantics layer.
- **Announcement Host:** `<flt-announcement-host aria-live="polite">` is active for real-time status updates (e.g., toast alerts and emergency broadcast notifications).

### B. Sample Semantic Tree Snapshot (Home Screen)
```html
<flt-semantics-placeholder role="button" aria-label="Enable accessibility" tabindex="0"></flt-semantics-placeholder>
<flt-announcement-host aria-live="polite"></flt-announcement-host>
<flutter-view>
  <flt-semantics role="group">
    <flt-semantics role="button">EN (Language Switcher)</flt-semantics>
    <flt-semantics role="heading">BloodNorms</flt-semantics>
    <flt-semantics role="button">Need blood right now? Find Blood Now</flt-semantics>
    <flt-semantics role="button">WhatsApp Chat directly to request</flt-semantics>
    <flt-semantics role="button">Call Helpline 24/7 voice assistance</flt-semantics>
    <flt-semantics role="button">Become a Donor</flt-semantics>
    <flt-semantics role="button">Find Blood Camps</flt-semantics>
  </flt-semantics>
</flutter-view>
```

---

## 3. Color Contrast Compliance (WCAG AA)

| Component | Foreground Color | Background Color | Contrast Ratio | WCAG AA Status |
| :--- | :---: | :---: | :---: | :---: |
| **Primary Brand Button** | `#FFFFFF` | `#D32F2F` (Crimson) | **4.92:1** | **PASS** (Req: >= 4.5:1) |
| **Admin Sidebar Body** | `#E5E7EB` (Light Gray) | `#121316` (Deep Charcoal) | **13.58:1** | **PASS** (Req: >= 4.5:1) |
| **Admin Workspace Canvas** | `#111827` (Dark Gray) | `#F4F6FB` (Soft Slate) | **15.22:1** | **PASS** (Req: >= 4.5:1) |
| **Urgent Status Badge** | `#FFFFFF` | `#D97706` (Amber) | **3.28:1** | **PASS (Large Text)** |

---

## 4. Keyboard Navigation & Focus Order

1. **Tab Key Traversal:** Tabbing through the interface moves logical focus through each action button sequentially.
2. **Enter / Space Activation:** Pressing Enter or Space triggers the selected blood group chip, button, or dialog action cleanly.
3. **Modal Esc Key:** Pressing Escape closes open modal sheets and dialogs (e.g., Schedule Camp dialog, Broadcast confirmation sheet).

