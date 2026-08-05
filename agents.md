# Avo - Toolkit for building internal tools with Rails and Hotwire

## Developing components

The `Avo::DiscreetInformationComponent` component was created by hand. Use that as a template for other components.

See the patterns applied in the `rb`, `erb` and `css` files.

Alwyas create lookbook previews for the components you develop.

Every lookbook preview should have a `default` view with some variations of the component.

Don't implement a component if the Figma MCP is not available and fails and alert the developer.

Never write emdashes in copy or docs.

#### CSS

- Use clean CSS and convert the variables to Tailwind CSS `@apply` statements where possible.
- add the new component to the `src/input.css` file.
- use the BEMCSS methodology for the component classes.
- when the width and height are the same, use the `size-` class instead of `width-` and `height-`.
- don't use `left`/`right` modifiers as we need to support RTL. Use `start`/`end` instead. Same for short names like `ml`, `mr`, `pl`, `pr`, `left`, `right`, etc.

#### Figma

- check the components and see if they use other components. If so, use the existing components.
- don't add the default color in `var()` statements when implementing them from Figma.
- when the Figma component has an "icon-mode", usually this doesn't need to be an option inn tha actual component but make it react properly to when the component doesn't have text or other elements.

#### SVGs

- use `svg` helper to render the SVGs.
- use the `helpers.svg` helper to render the SVGs only in view components, never in lookbook previews.
- use a string that is composed of `tabler/outline/{NAME_OF_ICON}` or `tabler/filled/{NAME_OF_ICON}` and the name of the icon and choose an existing icon from the library. if you can't think of one use `paperclip`, `info-circle`, or `external-link` for outgoing links.

#### Tailwind CSS

- when writing css try to use the `@apply` directive whenever you can and preserve the regular Tailwind syntax.
- when writing media queries, try to land in Tailwind's regular breakpoints and write the media query as a Tailwind prefix `sm:text-sm` instead of `@media (min-width: 640px) { .text-sm { font-size: 1rem; } }`.
- we work only with Tailwind CSS v4 and above. don't try to support anything below v4.

#### Naming conventions

- use header, sidebar, and body for the component areas.
- use `title` instead of `name` when you need to reference the title of a component.

#### Node.js

- use `yarn`, not npm

#### Files

## Javascript

We use StimulusJS for the javascript.
Aboid writing inline script tags in the HTML unless instructed so or mentioned some kind of "temporary" or "quick" solution .

Wherever you need to toggle the visibility of an element, use the `toggleHidden` helper function.

## HTML Structure

When toggling the visibility of some html elements, use the `hidden` HTML attribute instead of the `hidden` class.

## Ruby on Rails

Whenever possible use the `partial:` keyword when rendering partials unless needed otherwise.

### Class as a URL parameter (slug)

When a class travels in a URL (a scope, filter, action, or any selectable type), encode it as a readable slug, not the raw class name, and resolve it back by matching against the objects you already registered.

Never `constantize` the param. It is user input, and constantizing it means arbitrary class loading (autoload DoS, information disclosure, gadget surface). Match against a known set instead.

Parameterize: derive a stable slug from the class. Keep the full namespace path; do not `demodulize`, or nested classes collide (`A::Active` and `B::Active` both become `active`). `underscore` turns `::` into `/`; map that boundary to `-` so the URL builder does not `%2F` encode a slash.

```ruby
def self.param
  @param ||= name.underscore               # Avo::Scopes::Admin::NonAdmins => "avo/scopes/admin/non_admins"
              .delete_prefix("avo/scopes/") # => "admin/non_admins" (strip the type's conventional root)
              .tr("/", "-")                 # => "admin-non_admins"
end
```

Result: `/admin/resources/users?scope=admin-non_admins`

Class and module names are CamelCase, so `_` only comes from a word boundary and `-` only from a `::` boundary. `admin-non_admins` maps unambiguously to `Admin::NonAdmins`, and distinct nested classes never collide.

Deparameterize: match the computed slug against the registered set and return the class. Do not rebuild the class from the string.

```ruby
scopes.find { |scope| scope.param == params[:scope] }
```

Guards:

- Let `self.param` be overridden for a custom short slug (`scope=vip`), which also breaks the rare collision.
- Assert slug uniqueness within the set at boot; raise and point the author at `self.param` on conflict.
- During a transition, also accept the legacy value so bookmarked URLs keep working (`scope.param == p || scope.name == p`); drop the fallback a version later.

## Logging in (development & testing)

The dummy app at `spec/dummy` uses Devise for authentication. Avo is mounted at `/admin` and is wrapped in an `authenticate :user, ->(user) { user.is_admin? }` block, so you need an admin user to reach it.

#### Development (browser / `bin/dev`)

1. Seed the database to create the admin user:

   ```sh
   cd spec/dummy && rails db:seed
   ```

2. Visit `/users/sign_in` and log in with:
   - Email: `hi@avohq.io`
   - Password: `secreto` (override with the `AVO_ADMIN_PASSWORD` env var)

3. The admin panel lives at `/admin`.

#### Testing (RSpec + Capybara/Cuprite)

Do not drive the sign-in form in tests. Use the Devise/Warden test helpers instead:

- System & feature specs: `login_as(admin, scope: :user)` (Warden test mode is enabled in `spec/support/devise.rb`).
- Controller specs: `sign_in admin` (Devise's `ControllerHelpers`).
- Get an admin user from the shared context: `include_context "has_admin_user"`, which exposes `admin` via `create(:user, roles: {admin: true})`. The mix-in `TestHelpers::DisableAuthentication` (`spec/support/controller_routes.rb`) wires this up automatically.

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
bundle exec standardrb        # Ruby (StandardRB) -- note: .standard.yml sets `fix: true`, so this auto-fixes files
bundle exec erb_lint --lint-all   # ERB
yarn eslint app/javascript        # JS -- see caveat below
```
The JS lint config (`.eslintrc.json`) is the legacy eslintrc format and only works
with old ESLint. `package.json` pins ESLint v9, which (a) defaults to flat config
and (b) is incompatible with the `sort-imports-es6-autofix` plugin, so
`yarn eslint app/javascript` fails locally out of the box. CI works around this by
installing `eslint@6.8.0` (plus matching plugins) at job time before linting
(see `.github/workflows/lint.yml`). Do not "fix" this by changing the pinned version.

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
