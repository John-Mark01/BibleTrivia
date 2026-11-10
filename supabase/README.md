# Supabase

| Environment | Project | Used by |
|---|---|---|
| Dev | `sgdvlomeynxrsbdfvbrk` ("Bible Trivia Dev") | Debug builds |
| Production | `curjrjrzqgpdvizmnxhn` ("Bible Trivia") | Release builds |

## Migrations

- `20261110152446_baseline.sql`: snapshot of production as it was before migrations were tracked.
- `20261110153424_v1_backend.sql`: security lockdown, schema clean-up, consolidated RPCs, server-side grading, streak fix.

Both are applied to **dev**. Dev also has `seed.sql` content and a confirmed integration-test user.

## Promoting v1 to production

Production has **not** been migrated yet. The current App Store/TestFlight build (if any) uses the old API and stops working once this runs, so ship the new app at the same time.

1. Back up prod (Dashboard → Database → Backups).
2. Mark the baseline as already applied (prod *is* the baseline):
   ```sql
   create schema if not exists supabase_migrations;
   create table if not exists supabase_migrations.schema_migrations (version text primary key, statements text[], name text);
   insert into supabase_migrations.schema_migrations (version, name) values ('20261110152446', 'baseline');
   ```
3. Apply `20261110153424_v1_backend.sql` to prod.
4. Run the security advisors. Only the intended client RPCs should be listed.
5. Replace prod's test content with real content (the `topics` table holds test rows such as "another" ×4).
6. Auth settings for **both** projects:
   - URL Configuration → add `bibleTrivia://auth/callback` and `bibleTrivia://auth/reset-password` to the redirect URLs.
   - Enable leaked-password protection.
   - Upgrade Postgres when convenient (the advisor flags pending security patches).
