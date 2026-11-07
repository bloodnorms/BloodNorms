# ADR 002: Supabase (PostgreSQL 15 + PostGIS) as Central Backend

## Status
Accepted

## Context
Emergency blood matching is fundamentally a geospatial proximity problem. Finding the nearest verified blood banks and compatible volunteer donors within expanding concentric distance bands (0.5 km to 100 km) requires robust spatial indexing (`ST_DWithin`, spatial indexes `GIST`), Row Level Security for sensitive medical records, and real-time subscription channels for tracking donor dispatches.

## Decision
Use Supabase managed PostgreSQL with PostGIS extensions as the primary relational and spatial database, authentication provider, and Edge Function host.

## Consequences
### Positive
- Sub-millisecond geographic proximity queries using PostGIS spatial indexing.
- Native Row Level Security (RLS) guaranteeing tenant isolation and donor privacy.
- Deno Edge Functions collocated with the database for low-latency webhooks.

### Neutral / Trade-offs
- Connection pool limits during extreme traffic spikes require PgBouncer or direct pooler configuration.
