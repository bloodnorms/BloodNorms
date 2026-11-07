# ADR 003: 100% Free OpenStreetMap and Nominatim Geocoding

## Status
Accepted

## Context
Commercial mapping APIs (such as Google Maps Platform) enforce restrictive credit card billing, API quotas, and unpredictable per-request pricing that creates financial failure modes for public interest non-profit emergency services.

## Decision
BloodNorms exclusively uses OpenStreetMap (OSM) vector and raster tiles with `flutter_map` (Leaflet equivalent for Flutter) and OpenStreetMap Nominatim for forward place search and reverse geocoding.

## Consequences
### Positive
- Zero Google Maps billing risk, zero monthly API invoices, zero unexpected quota cutoffs during life-or-death emergencies.
- Fully open-source and customizable tile caching layers.

### Neutral / Trade-offs
- Nominatim public API enforces fair use rate limits (1 req/sec); client caches search results and delays typing debouncing to 400ms.

