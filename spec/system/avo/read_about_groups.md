# System spec groups (CI sharding)

We split system specs into CI `spec_group`s to reduce wall-clock CI time by running them in parallel.

Each group is a directory under `spec/system/avo/`:
- `group_1/`
- `group_2/`

The distribution was balanced by **approximate example count** (we counted `it "..."` per file and assigned files to keep groups even).

To avoid splitting “feature areas” across shards, we keep the main feature subfolders together:
- `filters/` lives in a single group
- `date_time_fields/` lives in a single group
- `key_value_field/` lives in a single group

Run one shard locally from `gems/avo/`:

```bash
bundle exec rake parallel:drop parallel:create parallel:migrate && bundle exec parallel_rspec spec/system/avo/group_1 spec/system/avo/group_2
```

Adding new system specs:
- Place new specs under one of the `group_*` folders (and occasionally rebalance if one group drifts).
