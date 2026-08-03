---
name: avo-aware
description: Keep the Avo admin panel in sync when you change a Rails model, migration, or add a capability — even when the request never mentions Avo. Use only in an app that has the `avo` gem in its Gemfile AND an `app/avo/` directory, when the user asks to add or change a model column, add a model, add an enum/status, create an association, or add a capability like "let admins approve orders" or "users can archive projects" — anything whose admin surface should be updated too. Does the Rails change first, then proposes the matching Avo change and routes it to the right vertical skill.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — dispatcher; the target skill states its own gem
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Keep the Avo admin in step with Rails changes

Many Rails apps run [Avo](https://docs.avohq.io) as their admin panel. When you change the Rails side — a migration, a model attribute, a new model, an enum, an association, or a new "admins can X" capability — the admin panel almost always needs a matching change: a field, a resource, a filter, an action, a policy method. But the request usually arrives phrased as **plain Rails, with no mention of Avo at all**: *"add a `status` column to `Project`"*, *"let admins approve orders"*, *"users can archive projects"*.

This skill is the **dispatcher**. It is the one skill allowed to fire on Rails-shaped, Avo-unmentioned requests. Its job is narrow and disciplined:

1. **Do the Rails change** the user actually asked for.
2. **Notice the Avo dimension** of that change.
3. **Ask** before touching the admin — propose the delta, don't sprawl into it silently.
4. **Delegate** the admin edit to the right vertical Avo skill.

It never owns the Avo edit itself. It routes.

---

## Gate first (CRITICAL)

**Before anything Avo-related, confirm this app actually uses Avo.** Most Rails apps do not. If you skip this gate you will misfire on every Rails project — offering admin-panel changes to people who have no admin panel.

Two conditions must **both** hold:

1. **The `avo` gem is in the bundle.** Grep the Gemfile:

   ```bash
   grep -nE "gem ['\"]avo" Gemfile
   ```

   (Also acceptable: a match in `Gemfile.lock` under `avo (`.)

2. **An `app/avo/` directory exists** with resources in it:

   ```
   Glob: app/avo/**/*.rb
   ```

**Decision rule:**

- **Both true → Avo is present.** Proceed with the full loop below.
- **Either false → Avo is NOT present.** Do the plain Rails task the user asked for and **stop**. Do **not** mention Avo, admin panels, resources, or this skill. The user asked for a Rails change; give them exactly that.

Run the gate silently. Only surface Avo once it has passed.

---

## The loop

Once the gate passes, run this loop for the change at hand: **detect → map → confirm → delegate.**

### 1. Detect

Look at what the user asked for and classify the Avo-relevant trigger. Any of these has an admin dimension:

- **A new or changed migration / model attribute** — a column added, renamed, or retyped.
- **A new model** — `Project`, `Order`, `Invoice`.
- **A new enum or state column** — `status`, `state`, `kind`, anything with a fixed set of values.
- **A new association** — `belongs_to`, `has_many`, `has_one`, `has_many :through`.
- **A capability phrased as a workflow** — *"admins can approve orders"*, *"users can archive projects"*, *"let editors publish posts"*. These map to an Avo **action** plus a **policy** method, not just a field.

If none of these apply (a pure service object, a bug fix, a view tweak with no schema or capability change), there is no Avo delta — just do the Rails work.

### 2. Map

Translate the detected change to its admin surface and the skill that owns it, using the **Routing table** below. For column-type inference, use the **Column-type → field mapping** table.

### 3. Confirm

**Do the Rails change the user asked for first.** Write the migration, the model code, the enum — whatever they requested — and make sure it's coherent on its own.

**Then surface the Avo delta and ask before writing any Avo file.** One short, concrete proposal:

> I added `status` to `Project` (enum: `draft`, `active`, `archived`). Want me to expose it in the Avo admin too — a badge field plus a status filter?

> I added `Order#approve` as a capability. In the admin that's an Avo action with a matching Pundit `approve?` policy method. Want me to add both?

Propose, don't sprawl. If the user says no, stop cleanly. If they say yes, delegate. If they gave you standing permission to keep the admin in sync (e.g. *"and update Avo too"*), you can skip the ask for that change.

### 4. Delegate

Hand the admin edit to the named vertical skill — invoke it if it's installed, otherwise follow its documented workflow and pull the current API from the [Docs](#docs). The dispatcher's job ends at the handoff; the vertical skill writes the resource, field, filter, action, or policy. If one change spans several surfaces (an enum → field **and** filter **and** action), route each part to its skill.

---

## Routing table

| Rails change | Avo surface to add | Skill to apply |
| ------------ | ------------------ | -------------- |
| New column | A `field` on the resource (infer `as:` from the column type) | `avo-fields` |
| New model | Generate the Avo resource | `avo-resources` |
| New enum / state column | A badge or select field **and** a filter — often also a state-transition action | `avo-fields` + `avo-filters` + `avo-actions` |
| New capability (*"admins can approve X"*) | An action **and** the Pundit policy method that authorizes it | `avo-actions` + `avo-authorization` |
| New association | An association field | `avo-associations` |
| *"only show active records by default"* | A default scope on the resource | `avo-filters` |
| *"let admins reorder these"* | `self.ordering` on the resource | `avo-record-reordering` |

---

## Column-type → field mapping

When a new column becomes a field, infer the `as:` option from the migration column type:

| Column type | Avo field `as:` |
| ----------- | --------------- |
| `string` | `:text` |
| `text` | `:textarea` (or `:trix` / rich text for long-form content) |
| `integer`, `decimal`, `float` | `:number` (use `:money` for currency amounts) |
| `boolean` | `:boolean` |
| `date` | `:date` |
| `datetime`, `timestamp` | `:date_time` |
| enum / fixed value set | `:select`, `:badge`, or `:status` |
| `references` / `belongs_to` | `:belongs_to` |
| `has_many` / `has_one` association | `:has_many` / `:has_one` |
| `json`, `jsonb` | `:key_value` (or `:code` for freeform structured data) |
| Active Storage attachment | `:file` (single) / `:files` (multiple) |

These are defaults, not laws. Let the semantics of the column win — a `string` holding an email is better as a text field with an email pattern; a `text` column holding Markdown is better as rich text. When you propose the field in the confirm step, name the `as:` you'll use so the user can redirect it.

---

## Docs

Whenever a delegated edit needs current API details, pull them from the Avo docs map so the authoring reflects the installed version rather than stale memory:

**`https://docs.avohq.io/4.0/docs-map.md`** — an index of every Avo 4 docs page and its headings, with links. Fetch it, then follow the link to the specific page (fields, resources, actions, filters, associations, authorization) the vertical skill needs.

---

## Report

When you're done, tell the user both halves plainly:

- **The Rails change you made** — the migration/model/enum/association you wrote.
- **The Avo change you proposed or made** — which admin surface, which field/filter/action/policy, and which vertical skill handled it. If the user declined the Avo change, say that the admin was left untouched so nothing is silently out of sync.

Keep it to a few lines. The user should be able to see, at a glance, that the model and its admin surface still agree.
