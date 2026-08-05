---
name: avo-actions
description: Build Avo actions — Ruby classes in `app/avo/actions/*.rb`, registered on a resource's `def actions` — that run a custom operation on selected records, a single record, or nothing at all, with optional form fields, a confirmation modal, feedback notifications, custom responses, and multi-step flows. Use when the user wants to let admins bulk-approve these orders, mark selected invoices as paid, add a button to export selected users to CSV, deactivate/ban a user from the admin, send a welcome email to selected records, trigger a background job for these records, add a Publish/Approve button on the post page, add a monthly report button, collect a reason when someone does something, add a confirmation dialog before an operation, or build a multi-step form/wizard in the admin.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — Community
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Avo Actions

An **action** is a plain Ruby class with a `handle` method that runs a custom operation from the admin UI — on the records the user selected, on a single record, or on nothing at all. It's the home for every "do something to these records" request: bulk-approve, mark as paid, deactivate a user, export to CSV, kick off a background job, generate a report.

- **File:** `app/avo/actions/<name>.rb`, class `Avo::Actions::<Name>` inheriting `Avo::BaseAction`.
- **Registration:** listed inside the resource's `def actions` method — that's what makes it show up in the resource's **Actions** dropdown.
- **License:** actions and select-all are **Community** (no paid gem required).

**Docs** — fetch on demand with WebFetch; prefer the raw `.md` (clean, no HTML):

- Guide (tasks + worked examples): https://docs.avohq.io/4.0/actions.md
- Reference (every registration option, class attribute, feedback + response method): https://docs.avohq.io/4.0/actions-api.md
- Select all (run an action on every matching record across pages): https://docs.avohq.io/4.0/select-all.md
- Docs map (find any other Avo page): https://docs.avohq.io/4.0/docs-map.md

Read the guide before implementing anything non-trivial, and the reference page whenever you need the exact signature/default of an option.

## When this applies

Reach for an action when the request is "let admins **do X** to **records** from the admin":

| Request (Avo-shaped or plain Rails) | Pattern |
| --- | --- |
| "Bulk-approve these orders", "mark selected invoices as paid", "deactivate the selected users" | [Bulk](#bulk-the-default) |
| "Add a Publish/Approve button on the post page", "ban this user" | [Single-record](#single-record) |
| "A monthly report button", "run this maintenance job", "export everything to CSV" | [Standalone](#standalone-no-records-needed) |
| "Collect a reason when someone bans a user", "ask for a message before sending" | [With fields](#collect-input-with-fields) |
| "Add a confirmation dialog", "make it ask before running" (or skip it) | [Confirmation](#confirmation-modal) |
| "Then download a file / redirect / refresh just the row" | [Responses](#control-what-happens-after) |
| "A multi-step form / wizard" | [multi-step flow](#multi-step-flows-wizards) |
| "Run it on all matching records, not just this page" | [Select all](#run-on-all-matching-records-select-all) |

Note the boundary: the action is what **runs the operation** and, by default, appears in the resource's **Actions** dropdown. If the user specifically wants it rendered as a **dedicated button or custom control** outside that dropdown (relabel a default button, a button in the row, a bespoke dropdown), that *placement* is a separate paid add-on — use the **`avo-custom-controls`** skill for it. Build the action here; wire the button there.

## Workflow

### 1. Generate the action

```bash
bin/rails generate avo:action toggle_inactive
```

Creates `app/avo/actions/toggle_inactive.rb` with a commented skeleton for `visible`, `fields`, and `handle`. Flags:

```bash
# Standalone action (runs without selected records)
bin/rails generate avo:action generate_monthly_report --standalone

# Namespaced -> app/avo/actions/admin/approve_user.rb, class Avo::Actions::Admin::ApproveUser
bin/rails generate avo:action admin/approve_user
```

If you're writing the file by hand, mirror that path/class convention exactly.

### 2. Write `handle`

`handle` holds the business logic. It receives keyword arguments — take what you need and swallow the rest with `**args`:

```ruby
# app/avo/actions/toggle_inactive.rb
class Avo::Actions::ToggleInactive < Avo::BaseAction
  self.name = "Toggle Inactive"

  def handle(query:, fields:, current_user:, resource:, **args)
    query.each do |record|
      record.update!(inactive: !record.inactive)
    end

    succeed "Toggled status for #{query.count} records"
  end
end
```

The keyword arguments:

- `query` — the selected record(s). **Always an array**, even for a single record (`records` is an alias).
- `fields` — values submitted through the action's form fields (see below).
- `current_user` — the authenticated user.
- `resource` — the Avo resource instance that triggered the action.
- `request` — the current `ActionDispatch::Request` (add `request:` to the signature to use it).

### 3. Register it on the resource

```ruby
# app/avo/resources/user.rb
class Avo::Resources::User < Avo::BaseResource
  def actions
    action Avo::Actions::ToggleInactive
    action Avo::Actions::SendWelcomeEmail, icon: "heroicons/outline/envelope"

    divider label: "Danger zone"
    action Avo::Actions::BanUser
  end
end
```

Registration options passed alongside the class:

- `icon:` — icon shown next to the action in the dropdown (Heroicons or Tabler path; default `"tabler/outline/player-play"`).
- `arguments:` — a Hash (or a proc returning one) of custom data available as `arguments` everywhere in the action class (`handle`, `fields`, and the modal blocks). Encrypted + Base64-encoded in URLs, so it's safe for sensitive values.
- `divider label: "..."` — a visual separator to group related actions.

With no further config the action shows on **Index** and **Show** (hidden on **New**), asks "Are you sure?" in a confirmation modal, runs `handle`, flashes a green success notification, and reloads the page.

## Action patterns

### Bulk (the default)
Iterate `query` — the checked rows on **Index**. Nothing special to set; this is the out-of-the-box behavior.

```ruby
def handle(query:, **args)
  query.each { |order| order.approve! }
  succeed "Approved #{query.count} orders"
end
```

### Single-record
Same `handle` — on **Show** (or via row controls) `query` is just that one record, still wrapped in an array. Use `visible` to pin it to a view when appropriate:

```ruby
self.visible = -> { view.show? }

def handle(query:, **args)
  post = query.first
  post.publish!
  succeed "Published #{post.title}"
end
```

### Standalone (no records needed)
For global reports, maintenance tasks, background jobs. Set the attribute (or generate with `--standalone`); it stays enabled with nothing selected and `handle` gets an empty `query`:

```ruby
class Avo::Actions::GenerateMonthlyReport < Avo::BaseAction
  self.standalone = true

  def handle(**args)
    ReportJob.perform_later(current_user)
    inform "Report queued — you'll get an email when it's ready."
  end
end
```

### Collect input with fields
Define `fields` to render form inputs in the modal; the submitted values arrive as `fields`. Same field DSL as resources. On a single record the fields are hydrated from it; otherwise they're plain inputs.

```ruby
def fields
  field :notify_user, as: :boolean
  field :message, as: :textarea
end

def handle(query:, fields:, **args)
  query.each do |user|
    user.deactivate!
    user.notify(fields[:message]) if fields[:notify_user]
  end
  succeed "Done"
end
```

### Confirmation modal
The modal is on by default. Customize its text (each may be a string or a block with access to `resource`, `record`, `view`, `arguments`, `query`), or turn it off for safe actions:

```ruby
self.name = "Release fish"
self.description = "Release the fish back into the ocean"
self.message = -> { record ? "Release #{record.name}?" : "Release the fish?" }
self.confirm_button_label = "Release"
self.cancel_button_label = "Keep"

self.confirmation = false               # skip the modal, run immediately on click
self.close_modal_on_backdrop_click = false  # don't lose a filled-in form on a stray click
```

### Give feedback
Queue one or more notifications from inside `handle` — call several to stack them. With no explicit feedback Avo shows a generic "Action ran successfully" info alert.

```ruby
succeed "Green — success"                      # green
inform "Blue — info"                            # blue
warn "Orange — heads up", timeout: :forever     # orange; stays until dismissed
error "Red — failure", timeout: 8000            # red; timeout in ms
silent                                           # suppress the default notification (e.g. before a redirect)
```

### Control what happens after
`handle` also picks the UI response. Default is a full-page `reload`; the last response method called wins:

| Method | Effect |
| --- | --- |
| `reload` | Full-page reload (default). |
| `redirect_to path` | Redirect elsewhere (accepts `allow_other_host:`, `status:`). |
| `download data, "file.csv"` | Trigger a file download. **Pair with `self.turbo = false`** for a real file response. |
| `keep_modal_open` | Keep the modal + user input (show an error and let them retry). |
| `close_modal` / `do_nothing` | Close the modal, leave the page as-is. |
| `reload_records(query)` | Refresh only the affected rows/cards. **Index only — not associations.** |
| `navigate_to_action Other, arguments: {...}` | Chain into another action (see below). |
| `append_to_response -> { [turbo_stream...] }` | Add your own turbo-stream responses. |

### Multi-step flows (wizards)
`navigate_to_action` passes `arguments` to a second action's modal — step 1 collects choices, step 2 renders only the relevant fields and performs the work. The second action is usually `self.visible = -> { false }` so it's reachable only through the flow. See the guide's "Build a multi-step flow" for a full two-file example.

### Trigger an action from a link
To open an action's modal from a field, dashboard card, or partial, call the class's `link_arguments` with a resource instance; it returns `[path, data]` for `link_to`:

```ruby
path, data = Avo::Actions::City::Update.link_arguments(
  resource: resource,
  arguments: { cities: [resource.record.id], render_name: true }
)
link_to resource.record.name, path, data: data
```

### Run on all matching records (select all)
When an index spans multiple pages, checking "Select all" offers to select **every matching record across all pages**, not just the visible ones. Avo serializes the (encrypted) query and rebuilds it in the action, so `handle`'s `query` covers the whole filtered set. This works out of the box — no code — but see the gotcha below if it silently disables itself.

## Gotchas

- **`query` is always an array.** Even a single-record action gets `[record]`. Use `query.first` for the one-record case; don't call record methods on `query` directly. `records` is an alias.
- **"My action doesn't show up" is usually the policy.** With Pundit, `act_on?` in the resource's policy gates action visibility (and `authorize` on the action gates it further). Check the policy first. See the **`avo-authorization`** skill.
- **The modal is a NEW request.** Params from the Index/Show page that opened it are **not** available in `fields`/`handle`. To prefill from the triggering page, parse `request.referer`:
  ```ruby
  field :source, as: :hidden, default: -> {
    URI.parse(request.referer).query.to_s.include?("hey=ya") ? :yes : :no
  }
  ```
- **`reload_records` is Index-only.** It doesn't work on association tables — use `reload` there.
- **Notification bodies truncate at ~320 characters.** Keep `succeed`/`error` messages short; put long output in a `download` or a redirect.
- **File downloads need `self.turbo = false`.** Otherwise Turbo intercepts the response and the download won't fire.
- **Standalone actions need `self.standalone = true`** — otherwise they're disabled when nothing is selected.
- **Select-all silently disabled?** Query serialization failed. A common cause: a model `normalizes` proc, which raises `TypeError: no _dump_data is defined for class Proc` when a filter hits the normalized attribute. Fix in `config/application.rb`:
  ```ruby
  config.active_record.marshalling_format_version = 7.1
  ```
- **Buttons/controls are a different skill.** "Add a button that runs this action" outside the Actions dropdown is the paid **`avo-custom-controls`** add-on. Build the action here; don't hand-roll control markup.

## Report

When done, tell the user:

- The action file created/edited (`app/avo/actions/<name>.rb`) and the resource(s) it was registered on.
- Which pattern it uses (bulk / single-record / standalone / with-fields / multi-step) and any key attributes set (`standalone`, `visible`, `authorize`, `confirmation`, `turbo`).
- What `handle` does, the feedback it gives, and the response after it runs (reload / redirect / download / reload_records / navigate_to_action).
- Any follow-ups the user still needs to do themselves: a Pundit `act_on?` entry, the `marshalling_format_version` config for select-all, or wiring a custom button via `avo-custom-controls`.
