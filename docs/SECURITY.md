# Security

mysihat ships as a **static bundle with no application server**. The
browser talks to Supabase directly. That shapes the whole threat model:
there is no trusted middle tier to validate anything, so **Postgres is the
only enforcement point**.

## What is in the client bundle, and why that's fine

`app/lib/core/config/supabase_config.dart` contains the Supabase project
URL and the **anon (publishable)** key. Both are compiled into
`main.dart.js` and readable by anyone who opens DevTools. That is the
intended design: the anon key only identifies the project and grants the
`anon` Postgres role. It authorises nothing on its own.

**The `service_role` key must never appear in this repository or in any
build output.** It bypasses Row Level Security entirely. If one is ever
committed, rotate it in the Supabase dashboard immediately — removing the
commit is not sufficient, because the bundle may already be deployed.

## Row Level Security is the authorisation layer

Every user-owned table has RLS enabled with owner-only policies:

| Table | Policy shape |
|---|---|
| `profiles` | Owner read/write, `(select auth.uid()) = id` |
| `insights` | Owner read/write, `(select auth.uid()) = user_id` |
| `habit_logs` | Owner read/write, `(select auth.uid()) = user_id` |
| `questionnaire_responses` | Owner insert + select only — append-only audit trail |
| `clinics` | Public read. Contains no personal data. |
| `national_mortality_baselines` | Public read. Published statistics. |

Two conventions matter:

- Policies target `TO authenticated` explicitly rather than relying on the
  default, so the `anon` role cannot reach user tables at all.
- `UPDATE` policies carry **both** `USING` and `WITH CHECK`. `USING` alone
  would let a user update a row they own into a row they don't — changing
  `user_id` to someone else's id.

See [DATABASE.md](DATABASE.md) for the full schema.

## Hardening already applied

Supabase's security advisor flagged two issues on the initial schema, both
fixed by the `harden_security_definer_functions` migration:

- `handle_new_user()` is `SECURITY DEFINER` (it must be, to insert a
  `profiles` row during signup) but `EXECUTE` was granted to `anon`,
  `authenticated` and `public`. Those grants were revoked — only the auth
  trigger calls it.
- `set_updated_at()` was `SECURITY DEFINER` with a mutable `search_path`, a
  standard privilege-escalation vector. It is now `SECURITY INVOKER`.

Advisors were clean after those migrations. Re-check them after any schema
change.

## Client-side validation is a UX feature, not a control

The questionnaire's validators (age 18–90, BMI 10–60, required fields) run
in the browser and can be bypassed trivially. They exist to give clear
feedback, which is what US 1.1 asks for. Any constraint that actually
matters for data integrity belongs in Postgres as a `CHECK` constraint —
see [ROADMAP.md](ROADMAP.md).

## Health data handling

- The risk engine runs **on-device**. Questionnaire answers are scored
  locally and only the resulting profile and insights payload are
  persisted, both under owner-only RLS.
- Output is explicitly framed as population-level statistical insight, not
  a medical diagnosis, and the app carries that disclaimer.
- There is no analytics or third-party telemetry in the bundle. Adding any
  would mean health-adjacent data leaving the user's browser, so it needs a
  deliberate decision rather than a default.

## HTTP response headers

`firebase.json` sets `X-Content-Type-Options: nosniff`, `Referrer-Policy:
strict-origin-when-cross-origin` and `X-Frame-Options: SAMEORIGIN` on all
responses. A Content-Security-Policy is not set yet — Flutter web's use of
`wasm-unsafe-eval` and Google Fonts makes a strict CSP non-trivial; see
[ROADMAP.md](ROADMAP.md).

## Reviewing changes

An automated security review of local changes needs a computable git diff.
This repository had **no commits at all** for its first several changes,
which is why earlier review attempts failed with "could not compute diff".
Keep the history committed so reviews work.

## Checklist before deploying

- [ ] `service_role` key appears nowhere in `app/` or `docs/`
- [ ] Supabase advisors show no new warnings
- [ ] Every new table has RLS enabled and owner-scoped policies
- [ ] New `UPDATE` policies have both `USING` and `WITH CHECK`
- [ ] `flutter analyze` and `flutter test` are clean
