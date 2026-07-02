# AGENTS.md

## Cursor Cloud specific instructions

Avo is a Ruby on Rails admin-panel **engine/gem**. There is no standalone app; you
develop and test it through the bundled dummy Rails app in `spec/dummy`. All
commands below are run from the repo root unless noted.

### Toolchain (already installed in the VM snapshot)
- Ruby `3.3.1` via `rbenv` (initialized in `~/.bashrc`; available in any login shell).
- Node + Yarn (classic) are pre-provisioned on `PATH`.
- `overmind` (used by `bin/dev`) and `foreman` are installed globally.
- PostgreSQL 16 is installed locally. `pg_hba.conf` is configured to `trust`
  `127.0.0.1`/`::1`, so the app connects as user `postgres` with an empty password
  (matching `spec/dummy/config/database.yml` defaults).

The update script only refreshes dependencies (`bundle install`, `yarn install`,
`spec/dummy` yarn). Everything below (starting Postgres, DB schema/seed, asset
builds, running the server) is NOT done by the update script — do it yourself.

### Start Postgres (needed every fresh VM boot; it does not auto-start)
```
sudo pg_ctlcluster 16 main start
```

### First-time / after-schema-change database setup
The dev DB and test DB are part of the snapshot, but if missing or stale:
```
# Development DB
AVO_LICENSE_KEY=license_123 bin/rails db:create
AVO_LICENSE_KEY=license_123 bin/rails db:migrate
AVO_LICENSE_KEY=license_123 AVO_ADMIN_PASSWORD=secret bin/rails db:seed
# Test DB (schema only — load separately, migrate does not target it)
AVO_LICENSE_KEY=license_123 RAILS_ENV=test bin/rails db:schema:load
```
Seeding creates an admin login: `hi@avohq.io` / `secret` (the email is hardcoded in
`spec/dummy/db/seeds.rb`; the password comes from `AVO_ADMIN_PASSWORD`, else `secreto`).

### Build assets (required before running the server or system tests)
```
yarn build:js
yarn build:css
yarn build:custom-js
```
`bin/dev` runs these as `--watch` processes, so during normal development they
rebuild automatically.

### After pulling/merging main (non-obvious gotchas)
- The dev group includes `actual_db_schema`, which treats migrations from other
  branches as "phantom" and can roll them back / hide them after a branch switch or
  merge. Symptom: the app raises `ActiveRecord::PendingMigrationError` while
  `bin/rails db:migrate` / `db:migrate:status` claim nothing is pending. Fix by
  reloading the dev DB from the (up-to-date) `schema.rb`:
  ```
  AVO_LICENSE_KEY=license_123 RAILS_ENV=development bin/rails db:drop db:create
  AVO_LICENSE_KEY=license_123 RAILS_ENV=development bin/rails db:schema:load
  AVO_LICENSE_KEY=license_123 RAILS_ENV=test bin/rails db:schema:load
  AVO_LICENSE_KEY=license_123 AVO_ADMIN_PASSWORD=secret RAILS_ENV=development bin/rails db:seed
  ```
  Always pass `RAILS_ENV` explicitly and run `db:schema:load` as its own command
  (chaining `db:drop db:create db:schema:load` in one invocation sometimes leaves the
  schema only partially loaded).
- If the server boots with a stale `NoMethodError` on a config setter that exists in
  `lib/avo/configuration.rb`, clear the bootsnap cache: `rm -rf spec/dummy/tmp/cache/bootsnap*`.
- If `bin/dev` reports "Overmind is already running", remove the stale socket: `rm -f .overmind.sock`.

### Run the dummy app
```
AVO_LICENSE_KEY=license_123 bin/dev      # starts web + js/css/custom-js watchers via overmind
```
The server listens on `http://localhost:3030`. Avo is mounted at `/admin`
(root `/` redirects there). Log in with `hi@avohq.io` / `secret`.

Note: `bin/dev` uses a `&>` bashism in its overmind/foreman detection that misfires
under `dash`; this is why `overmind` is installed (the `foreman` fallback branch is
never reached). Do not "fix" `bin/dev` for this.

### Lint
```
bundle exec standardrb        # Ruby (StandardRB)
bundle exec erb_lint --lint-all   # ERB
yarn eslint app/javascript        # JS
```

### Tests
Tests run against `RAILS_ENV=test` with `AVO_LICENSE_KEY=license_123`.
```
bin/test            # everything (slow)
bin/test unit       # feature + controller + component (fast)
bin/test system     # system/browser tests (builds assets first, slow)
bin/test ./spec/requests/avo/home_request_spec.rb   # single file
```
System tests use `cuprite` (headless Chrome). DB-backed specs need the test DB
schema loaded (see above).
