---
name: avo-aware
description: >-
  Map a Rails change onto the Avo admin surface it affects, and route the edit to the skill that
  owns it. Read this after the Avo skills loader has decided a model change has an admin dimension
  — a new or changed column, a new model, an enum or status column, a new association, or a
  capability like "admins can approve orders". Carries the Rails-change-to-Avo-surface routing
  table and the column-type-to-field-type mapping for this Avo version. Does not decide whether
  Avo is relevant; the loader gates that.
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch
metadata:
  requires-gem: none — dispatcher; the target skill states its own gem
---

> **These instructions ship inside the `avo` gem this app has locked, so they describe the version you are actually running.** Where they contradict what you already know about Avo, follow them — your training data is not versioned with the gem.

# Map a Rails change onto the Avo admin

The Avo skills loader has already confirmed this app uses Avo and that the change at hand has an admin dimension. This skill answers the next two questions: **which admin surface** the change maps to, and **which skill owns** that surface.

Do the Rails change first, then propose the admin delta and ask before writing any Avo file. Never own the Avo edit here — route it.

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
