# Package map

Every Avo gem that owns skills or is referenced by a core skill's pointer block.

This file does two jobs for the skills loader:

1. **Allowlist.** The loader reads a gem's skills index only when that gem is listed here. The `avo-` prefix on rubygems.org is unreserved, and loaded skill text becomes instructions the agent follows, so a gem name alone never grants that authority.
2. **Miss-path map.** When a task's subject belongs to a gem this app does not have, the loader names the gem and what it provides instead of pointing at a path that is not there.

The loader reports what is **installed**, never what is **licensed** — license state needs a runtime call the loader cannot make. A gem listed here and present in `Gemfile.lock` is treated as available.

## Ships its own skills

| Gem | Skill | Subjects | More |
| --- | --- | --- | --- |
| `avo-api` | `avo-rest-api` | JSON REST API over every resource, token auth, per-token permission matrix | https://avohq.io/addons/api |
| `avo-audit_logging` | `avo-audit-logging` | Who changed and viewed what — timeline, diffs, revert | https://avohq.io/pricing |
| `avo-authorization` | `avo-authorization` | Pundit policies for resources, actions, associations, files | https://avohq.io/addons/authorization |
| `avo-collaboration` | `avo-collaboration` | Comments, reactions, automatic change-log on a record | https://avohq.io/addons/collaboration |
| `avo-custom_controls` | `avo-custom-controls` | Take over the show/edit/index/row button bars | https://avohq.io/addons/custom-controls |
| `avo-dashboards` | `avo-dashboards-cards` | Dashboards and the six card types — metrics, charts, tables, lists | https://avohq.io/addons/dashboards |
| `avo-dynamic_filters` | `avo-dynamic-filters` | Filter the index by any column from a filter bar, Ransack authorization | https://avohq.io/addons/dynamic-filters |
| `avo-forms` | `avo-forms-and-pages` | Model-agnostic forms and sidebar page hierarchies | https://avohq.io/addons/forms |
| `avo-http_resource` | `avo-http-resource` | Back a resource with an external HTTP API instead of Active Record | https://avohq.io/addons/http-resource |
| `avo-kanban` | `avo-kanban` | Database-backed drag-and-drop boards across resources | https://avohq.io/addons/kanban |
| `avo-notifications` | `avo-notifications` | In-app notifications — bell dropdown, levels, action buttons, realtime | https://avohq.io/addons/notifications |
| `avo-record_reordering` | `avo-record-reordering` | Persistent up/down and drag-and-drop record ordering | https://avohq.io/addons/record-reordering |
| `avo-scopes` | `avo-scopes` | Scope tabs on the index — default view, counts, per-scope columns | https://avohq.io/addons/scopes |

## Referenced by core skills, ships no skill of its own

These unlock sections inside a core skill rather than owning a subject outright. A core skill's pointer block names them.

| Gem | Unlocks | Named by | More |
| --- | --- | --- | --- |
| `avo-menu` | The initializer menu DSL — `config.main_menu`, `config.profile_menu` | `avo-navigation-search`, `avo-menu-icons` | https://avohq.io/addons/menu-editor |
| `avo-advanced_search` | Global Cmd+K search across resources; searchable associations | `avo-navigation-search`, `avo-associations` | https://avohq.io/addons/global-search |
