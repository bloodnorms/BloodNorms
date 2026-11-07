# ADR 001: Flutter + Dart Cross-Platform Framework

## Status
Accepted

## Context
BloodNorms requires high-frame-rate (60fps) mobile applications for emergency requesters and volunteer blood donors on Android and iOS, alongside responsive web interfaces for blood bank operators and administrative emergency coordinators. Emergency situations demand immediate responsiveness, high contrast, and tactile physical feedback without platform fragmentation.

## Decision
Adopt Flutter 3 (Dart 3) as the single unified frontend engineering framework across Web, Android, and iOS.

## Consequences
### Positive
- 100% code sharing for domain business logic, data models, PostGIS proximity calculations, and Apple Cupertino design system tokens.
- Native compiled performance (AOT) on mobile and CanvasKit/HTML rendering on Web.
- Instant hot-reload during pairing and active refactoring.

### Neutral / Trade-offs
- Web bundle size requires standard PWA caching techniques.
- Native background services require platform channels when needed.
