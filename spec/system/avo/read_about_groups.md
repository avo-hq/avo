# System spec groups (CI sharding)

We split system specs into CI `spec_group`s to reduce wall-clock CI time by running them in parallel.

Each group is a directory under `spec/system/avo/`:
- `group_1/`
- `group_2/`
- `group_3/`

The distribution was balanced by **approximate example count** (we counted `it "..."` per file and assigned files to keep groups even).

To avoid splitting “feature areas” across shards, we keep the main feature subfolders together:
- `filters/` lives in a single group
- `date_time_fields/` lives in a single group
- `key_value_field/` lives in a single group

Run one shard locally from `gems/avo/`:

```bash
bundle exec rake parallel:drop parallel:create parallel:migrate && bundle exec parallel_rspec spec/system/avo/group_1
```

Adding new system specs:
- Place new specs under one of the `group_*` folders (and occasionally rebalance if one group drifts).

Rebalance prompt (copy/paste):
> The system spec shards are getting uneven. Please rebalance `spec/system/avo/group_1`, `group_2`, `group_3` to be roughly equal by RSpec example count (you can approximate by counting `it` occurrences). Keep feature folders together (don’t split `filters/`, `date_time_fields/`, `key_value_field/` and other directories that contain system specs across groups). Provide the `git mv` commands you would run.
