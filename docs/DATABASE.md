# HealthPath Database (Supabase)

**Project:** Wahid-Islam's Project  
**Ref:** `loqwoiizinnshwrgaunj`  
**URL:** https://loqwoiizinnshwrgaunj.supabase.co  
**Region:** `ap-southeast-1`

All app persistence uses Supabase Auth + Postgres. The earlier MongoDB
backend has been deleted entirely — see [CLEANUP.md](CLEANUP.md).

## Tables

| Table | Purpose | Access |
|-------|---------|--------|
| `profiles` | User lifestyle profile (1:1 with `auth.users`) | Owner R/W (`authenticated`) |
| `insights` | Latest risk-engine JSON payload | Owner R/W |
| `habit_logs` | Daily completed habit IDs | Owner R/W |
| `clinics` | Klinik Kesihatan directory | Public read (`anon` + `authenticated`) |
| `questionnaire_responses` | Epic 1.0 (US 1.1) append-only questionnaire snapshot per submission | Owner insert + select (`authenticated`) |
| `national_mortality_baselines` | DOSM-inspired cause-of-death baseline rates by cause/gender/age band | Public read (`anon` + `authenticated`) |

### `questionnaire_responses` (Epic 1.0 / US 1.1)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `uuid` | PK, `gen_random_uuid()` |
| `user_id` | `uuid` | FK → `profiles.id` |
| `answers` | `jsonb` | `{fullName, age, gender, state, activityLevel, dietHabit, smoking, bmi, highBloodPressure}` |
| `submitted_at` | `timestamptz` | `now()` |

Policies: `questionnaire_insert_own` (`INSERT`, `authenticated`, `WITH CHECK auth.uid() = user_id`),
`questionnaire_select_own` (`SELECT`, `authenticated`, `USING auth.uid() = user_id`). One row is
inserted per profile-wizard "finish" via `QuestionnaireRepository.submit()`
(`app/lib/controller/repositories/questionnaire_repository.dart`) — the mutable `profiles` row
still holds the *current* answers; this table is an immutable audit trail of every submission.

`insights.payload` (jsonb) gained new fields for Epic 1.0 US 1.2/1.3 —
`peerAverageHealthAge`, `healthAgeDelta`, `projectedHealthAgeFollowPlan`,
`projectedHealthAgeNoChange`, `nationalComparisonHeadline(Bm)` — no schema
migration needed since the column is `jsonb`; see `docs/EPIC_1.md`.

## Auth

- Supabase Auth email/password.
- Trigger `on_auth_user_created` → `handle_new_user()` inserts a `profiles` row.
- Client also upserts profile after register as a safety net.

## RLS principles

- Every user table has RLS enabled.
- Policies use `TO authenticated` + `(select auth.uid()) = user_id/id`.
- UPDATE policies include both `USING` and `WITH CHECK`.
- Clinics are intentionally public-read (no PII).
- Client uses the **anon/publishable** key only — never `service_role`.

## Risk engine

Population risk scoring runs **on-device** in Dart (`controller/services/risk_engine.dart`).  
Results are stored in `insights.payload` (jsonb). Output is statistical insight, not a medical diagnosis.

## Migrations applied

1. `healthpath_core_schema` — tables, RLS, grants, clinics seed, signup trigger
2. `fix_handle_new_user_trigger` — SECURITY DEFINER signup helper
3. `harden_security_definer_functions` — revoke public EXECUTE; fix `search_path`

## Validation

Age (18–90) and BMI (10–60) bounds are currently enforced only by the
Flutter form, not by `CHECK` constraints. See [ROADMAP.md](ROADMAP.md).

## Related

- [SECURITY.md](SECURITY.md) — why the anon key in the client bundle is safe,
  and the RLS policy conventions that make it so
- [EPIC_1.md](EPIC_1.md) — which columns back which acceptance criteria
