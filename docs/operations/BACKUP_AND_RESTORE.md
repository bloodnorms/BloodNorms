# BloodNorms — Backup, Recovery & PITR Runbook (BACKUP_AND_RESTORE.md)

**Role:** Staff Database Reliability Engineer  
**Scope:** PostgreSQL 15 Core Database, PostGIS Extension, Storage Buckets  
**Version:** 1.0.0

---

## 1. Objectives & SLAs

| Metric | Target | Description |
|---|---|---|
| **Recovery Point Objective (RPO)** | **<= 15 minutes** | Maximum allowable data loss in the event of catastrophe. |
| **Recovery Time Objective (RTO)** | **<= 60 minutes** | Maximum allowable time to restore full service availability. |
| **Backup Retention** | **30 days** | Daily encrypted snapshots retained across geographic regions. |

---

## 2. Backup Architecture

1. **Continuous WAL Archiving (PITR):**
   - Write-Ahead Logs (WAL) are streamed continuously to redundant cloud object storage (AES-256 encrypted).
   - Enables restoring the database to any specific second within the last 7 days.
2. **Automated Daily Logical Dumps:**
   - Generated daily at 02:00 IST via `pg_dump`:
     ```bash
     pg_dump -Fc -h $DB_HOST -U $DB_USER -d $DB_NAME -f bloodnorms_backup_$(date +%Y%m%d).dump
     ```
   - Encrypted with GPG before transmission to secondary backup vaults.

---

## 3. Step-by-Step Restoration Procedure

### Step 1: Declare Incident & Activate Maintenance Mode
Notify the team and switch traffic to maintenance mode:
```bash
# In admin console or via Supabase CLI
supabase db remote set app_settings.kill_switch = '{"enabled": true}'
```

### Step 2: Provision Target Recovery Instance
In Supabase dashboard or Terraform:
1. Select **Database** -> **Backups**.
2. Select **Point in Time Recovery (PITR)**.
3. Specify target recovery timestamp (e.g. 10 minutes prior to corrupting incident).
4. Launch restoration to new isolated staging instance.

### Step 3: Run Integrity & Verification Gates
Before repointing production traffic:
```sql
-- 1. Verify schema migration count
select count(*) from supabase_migrations.schema_migrations;

-- 2. Verify audit logs immutability trigger exists
select tgname from pg_trigger where tgname = 'trg_audit_logs_immutable';

-- 3. Verify zero donor health answers leaked into logs
select count(*) from public.audit_logs where payload::text ~* 'health|medical|disease';
```

### Step 4: Promote Instance & Clear Kill Switch
Repoint DNS and environment variables (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) to the restored instance and deactivate maintenance mode.
