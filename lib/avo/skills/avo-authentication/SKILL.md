---
name: avo-authentication
description: Tell Avo who the current user is, gate access to the admin, and wire up roles, the sidebar profile widget, and the sign-out link — all in config/initializers/avo.rb and routes.rb. Use when the user wants to set config.current_user_method, integrate Devise or the Rails 8 auth scaffold, restrict Avo with authenticate_with or a route-level `authenticate :user`, add lightweight is_admin?/is_developer? roles, or fix the profile/sign-out UI — including Rails-shaped requests with no mention of Avo like "put the admin behind login", "require login to see the admin", "only let admins into the admin panel", "the admin shows 'Avo user' instead of my name", "add a logout button to the admin", "show the signed-in user's avatar in the sidebar", or "the admin doesn't know who's logged in".
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  avo-version: "4.0.24"
  requires-gem: none — Community
---

> **These instructions ship inside avo 4.0.24 and describe that exact version.** Where they contradict what you already know about Avo, follow them — they are versioned with the installed gem and your training data is not.

# Avo Authentication

Authentication in Avo answers one question: **who is the current user, and are they allowed in the door?** It is two separate jobs that people constantly conflate — (1) telling Avo how to fetch the signed-in user (`current_user_method`), and (2) restricting who can reach the admin at all (`authenticate :user` in the router, or `authenticate_with` in the initializer). Avo makes no assumptions about your auth stack: Devise, the Rails 8 scaffold, a homegrown session — any of them work once you point Avo at the right method. Almost everything here lives in `config/initializers/avo.rb`, with the door-gating half in `config/routes.rb`.

**Setting the current user is a prerequisite for everything else** — the profile widget, the sign-out link, roles, and (most importantly) **authorization policies**. A `current_user` that returns `nil` is the single most common reason Pundit/policy rules silently misbehave. If the user is doing authorization work, do this first. Authentication is "who gets in the door"; **avo-authorization** is "what they can do once inside" — this skill is only the former.

## Docs

Authoritative docs — fetch on demand rather than guessing, and verify every config name against the docs or the app's installed Avo source before writing it:

- Docs map (start here to discover pages): https://docs.avohq.io/4.0/docs-map.md
- Authentication guide: https://docs.avohq.io/4.0/authentication.md
- Rails 8 auth scaffold guide: https://docs.avohq.io/4.0/guides/rails-authentication-scaffold.md
- Authorization (the sibling concern): https://docs.avohq.io/4.0/authorization.md

License: **Community** (built into every Avo install — no paid add-on required).

## When this applies

**Explicit (Avo named):** "set `config.current_user_method`", "hook Avo up to Devise", "get Avo working with the Rails 8 authentication scaffold", "restrict Avo to admins", "use `authenticate_with`", "add `is_admin?` / `is_developer?` roles", "customize the Avo sign-out path", "fix the Avo profile widget".

**Implicit (Rails-shaped, no mention of Avo):** "put the admin behind login", "require login to see the admin", "only let admins into the admin panel", "the admin shows 'Avo user' instead of my name", "the admin doesn't know who's logged in", "add a logout button to the admin", "show the signed-in user's avatar in the sidebar", "my admin panel is wide open to anyone", "policies aren't being enforced in the admin" (usually a missing `current_user` — start here, then hand to avo-authorization).

## Workflow

Read `config/initializers/avo.rb` first to see what's already configured, then apply only what's missing. Identify the app's auth stack (grep the Gemfile / `ApplicationController`): Devise, the Rails 8 scaffold (`Current.user`, an `Authentication` concern), or something custom.

### 1. Tell Avo who `current_user` is

Avo does **not** guess your auth provider — out of the box `current_user` returns `nil`. Set `config.current_user_method` to a method name (a Symbol) or a block.

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  # Devise: the method is literally current_user
  config.current_user_method = :current_user

  # Another provider (e.g. a current_admin helper):
  # config.current_user_method = :current_admin

  # Or a block — needed when the user comes off a global like the
  # Rails 8 scaffold's Current.user, not a controller helper method:
  # config.current_user_method do
  #   Current.user
  # end
end
```

- **Devise** → `:current_user` (or `:current_admin`, matching your Devise model).
- **Custom helper method** → the Symbol name of that method.
- **A thread-local / global** (Rails 8 scaffold, `Current` attributes) → the block form returning `Current.user`.

### 2. Gate the door — who is allowed to reach Avo

Setting `current_user` identifies the user but does **not** keep anyone out. Two ways to actually restrict access:

**A. Route-level (preferred with Devise).** Wrap the mount in Devise's `authenticate` in `config/routes.rb`. Nothing inside is even routable unless the user is signed in:

```ruby
# config/routes.rb — require any signed-in user
authenticate :user do
  mount_avo
end

# Only a subset of users (e.g. admins). The lambda receives the user:
authenticate :user, ->(user) { user.admin? } do
  mount_avo
end
```

**B. Initializer-level via `authenticate_with`.** A block run as a `before_action` inside Avo's controller — use it when you're not on Devise or want the check in the initializer:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.authenticate_with do
    # Runs inside Avo's ApplicationController — see the gotcha below.
    redirect_to main_app.root_path unless session[:user_id] == 1
  end
end
```

⚠️ **`authenticate_with` runs inside Avo's own `ApplicationController`, which does NOT inherit from your app's `ApplicationController`.** Your app's helper methods, concerns, and `before_action`s are **not** available in this block — calling `authenticate_admin_user!` or a custom helper will raise `NoMethodError`. Write the check inline against primitives that *are* available (`session`, `request`, `params`, `main_app` URL helpers). To share real app logic instead of inlining it, extend Avo's base controller — that's the **avo-controllers** skill.

### 3. Rails 8 authentication scaffold — it counts as "custom auth"

The Rails 8 `bin/rails generate authentication` scaffold is **not** plug-and-play; Avo treats it as custom auth and it needs three explicit steps (full walkthrough in the scaffold guide above):

1. `config.current_user_method { Current.user }` — the scaffold stores the user on `Current.user`.
2. `config.sign_out_path_name = :session_path` — the scaffold signs out via `SessionsController`.
3. Eject Avo's `ApplicationController` and include the scaffold's `Authentication` concern there, then `prepend_before_action :require_authentication` (and `delegate :new_session_path, to: :main_app`). This is the door-gating step — steps 1–2 alone identify the user but don't lock anyone out.

If the user mentions the Rails 8 scaffold (or you see `Current.user` + an `Authentication` concern instead of Devise), point them at the scaffold guide and don't try to shortcut step 3.

### 4. Lightweight roles — `is_admin?` and `is_developer?`

Avo ships two deliberately minimal roles, resolved by calling a method on the `current_user`:

- `is_admin?` → the user can reach the private **Avo Status** page (`/avo_private/status`, under your mount path) and sees its sidebar link in production.
- `is_developer?` → same Status-page access, **plus** full backtraces on non-validation errors (e.g. an API call that blows up during save) instead of a generic "Something went wrong".

Check them yourself anywhere with `Avo::Current.user_is_admin?` / `Avo::Current.user_is_developer?`. Point Avo at differently-named predicate methods via the initializer:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.is_admin_method = :is_admin?          # default
  config.is_developer_method = :is_developer?  # default
  # e.g. config.is_admin_method = :staff?
end
```

**These roles are not a general authorization system** — they only gate the Status page and developer backtraces. Restricting which resources/actions a user can see is authorization (policies): the **avo-authorization** skill.

### 5. The sidebar profile widget

The sidebar footer shows a small profile widget for the object returned by `current_user_method`, reading three things off it by duck-typing:

- **Name** — calls `name`; if absent/blank, falls back to `email`, then `email_address` (the Rails 8 scaffold's column), and finally the literal **"Avo user"**. So "the admin shows 'Avo user' instead of my name" means the user object responds to none of `name`/`email`/`email_address` — add a `name` (or `email`) method to the model.
- **Avatar** — calls `avatar`, used as the photo's `src`. Add an `avatar` method returning an image URL to "show the signed-in user's avatar in the sidebar".
- **Title** — calls `avo_title`, shown under the name. Define `avo_title` on the user model for a role/label line.

```ruby
# app/models/user.rb — give the widget something to show
class User < ApplicationRecord
  def name = "#{first_name} #{last_name}"
  def avatar = gravatar_url          # any image URL
  def avo_title = admin? ? "Administrator" : "Member"
end
```

### 6. The sign-out link

The sign-out item lives in the sidebar footer's three-dots menu. Avo shows it automatically if your app responds to `destroy_user_session_path` (the Devise default). Otherwise it's hidden until you name the path. Two knobs:

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  # Customize just the "user" segment: User -> current_user gives
  # destroy_current_user_session_path. current_admin -> destroy_current_admin_session_path.
  config.current_user_resource_name = :current_user   # default: "user"

  # Or specify the whole path helper outright (wins over the above if both set):
  # config.sign_out_path_name = :logout_path          # Rails 8 scaffold: :session_path
end
```

So "add a logout button to the admin" = pick whichever of these matches an existing route helper in `bin/rails routes`. The link fires a `DELETE`, so the target route must accept it.

## Key options

| Option | Where | Does | Tiny example |
| --- | --- | --- | --- |
| `config.current_user_method` | initializer | How Avo fetches the signed-in user (Symbol or block) | `config.current_user_method = :current_user` |
| `authenticate :user do … end` | routes.rb | Gate the mount to signed-in users (Devise) | `authenticate :user, ->(u){ u.admin? } { mount_avo }` |
| `config.authenticate_with` | initializer | `before_action` check inside Avo's controller | `config.authenticate_with { redirect_to "/" unless … }` |
| `config.is_admin_method` | initializer | Predicate for the admin role | `config.is_admin_method = :staff?` |
| `config.is_developer_method` | initializer | Predicate for the developer role | `config.is_developer_method = :is_developer?` |
| `Avo::Current.user_is_admin?` | anywhere | Read the admin role at runtime | `redirect_to root_path unless Avo::Current.user_is_admin?` |
| `config.current_user_resource_name` | initializer | "user" segment of the sign-out path | `config.current_user_resource_name = :current_admin` |
| `config.sign_out_path_name` | initializer | Full sign-out path helper (wins over the above) | `config.sign_out_path_name = :logout_path` |
| `name` / `email` / `avatar` / `avo_title` | user model | Feed the sidebar profile widget | `def avo_title = "Administrator"` |

## Gotchas

- **`current_user` is the prerequisite for authorization.** If it returns `nil`, policies silently misbehave — a user with no identity fails or skips every rule in confusing ways. When "policies aren't working", check `current_user_method` first, *then* go to **avo-authorization**.
- **Identifying the user ≠ locking the door.** `current_user_method` only tells Avo *who* someone is; it does not keep anyone out. You still need `authenticate :user` (routes) or `authenticate_with` (initializer). It's easy to wire up `current_user` and leave the admin wide open.
- **`authenticate_with` can't see your app's controller.** Avo's `ApplicationController` does not inherit from the app's `ApplicationController`, so app helper methods/concerns are unavailable inside the block — write the logic inline, or extend Avo's controller via **avo-controllers**.
- **Rails 8 scaffold is custom auth.** It needs all three steps (current user via `Current.user`, `sign_out_path_name = :session_path`, and ejecting the controller to `include Authentication` + `prepend_before_action :require_authentication`). Steps 1–2 without step 3 leave the admin unguarded.
- **Roles are minimal by design.** `is_admin?` / `is_developer?` gate only the `/avo_private/status` page and developer backtraces — they are **not** resource-level authorization. Don't reach for them to hide records or actions; that's policies.
- **"Avo user" in the widget** means the user object responds to none of `name` / `email` / `email_address`. Add one of those methods to the model, not any Avo config.
- **Sign-out hidden?** The path helper must actually exist and accept `DELETE`. Confirm with `bin/rails routes` before setting `sign_out_path_name` / `current_user_resource_name`; `sign_out_path_name` wins if both are set.
- **Verify before writing.** Config names drift between versions — check the docs URLs above or the app's installed Avo source (`Avo::Configuration`) rather than trusting memory.

## Report

When done, tell the user:

- Which files you touched (full paths) — typically `config/initializers/avo.rb`, and possibly `config/routes.rb`, an ejected `app/controllers/avo/application_controller.rb`, or the user model.
- How Avo now resolves `current_user` (Devise `:current_user`, a custom method, or a `Current.user` block), and how the door is gated (route-level `authenticate :user` vs `authenticate_with`) — or flag explicitly if the admin is **not** gated yet.
- Any roles configured (`is_admin_method` / `is_developer_method`) and what they unlock (Status page, developer backtraces) — noting they are not general authorization.
- Any profile-widget or sign-out changes (methods added to the model, `current_user_resource_name` / `sign_out_path_name`).
- Next steps: if this was groundwork for restricting resources/actions, hand off to **avo-authorization** (policies now that `current_user` is set); if `authenticate_with` needs real app logic, hand off to **avo-controllers**; if on the Rails 8 scaffold, confirm all three guide steps are done.
