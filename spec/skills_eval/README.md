# Skills loader evaluation

Everything else about the skills loader is covered by `spec/lib/avo/skills/` — packaging, frontmatter, index integrity, and every resolver failure branch. Two things are not, because no test in this repo can observe them:

1. **Does the pointer skill trigger?** Users type "add a filter to Post", not "load the Avo skills". If the description does not fire, the whole mechanism is inert and nothing reports an error.
2. **Does the loaded text beat the model's priors?** Models carry strong Avo 3 knowledge and Avo 4 changed APIs. A model that reads the skill and then answers from memory produces a confident wrong diff — the exact failure this design exists to prevent.

Both fail *silently*. That is why they are measured against a stated bar rather than left to judgment.

## Pass bar

From `prompts.yml`:

| Metric | Bar |
| --- | --- |
| Trigger rate | ≥ 90% of `trigger` prompts fire the loader and reach the expected skill or gem branch |
| Prior-conflict rate | 100% of `prior_conflict` cases follow the loaded text |
| False triggers | 0 of the `no_trigger` prompts fire the loader |

The prior-conflict bar is 100% because a single failure there means an agent shipped wrong code while believing it was following version-pinned instructions. There is no acceptable rate above zero for that.

## Running it

This is a manual evaluation. It is deliberately not in CI: it needs a real agent in the loop, and a scored run costs real model time.

1. Install the loader into a scratch Rails app with Avo: `rails g avo:skills`.
2. For each `trigger` prompt, start a fresh agent session and send the prompt verbatim. Record whether the loader fired and which skill files were read.
3. For each `no_trigger` prompt, do the same and record whether the loader fired at all.
4. For each `prior_conflict` case, let the agent produce a diff and score it against `scored_on`.
5. Record the result below.

Fresh sessions matter. Once the loader has fired in a session its content is in context, so a later prompt in the same session tells you nothing about triggering.

## Runs

| Date | Avo version | Trigger | Prior conflict | False triggers | Notes |
| --- | --- | --- | --- | --- | --- |
| 2026-08-03 | 4.0.24 (branch) | **14/15 (93%)** | **3/3 pass** (diffs reviewed by a maintainer) | **0/4** | `claude -p` in `spec/dummy`. The one miss was #11 "make this board drag-and-drop": the app has no board, and the agent correctly asked which one rather than guessing. Corpus defect, not a trigger failure. Prior-conflict evidence: #17 used `value.split(" to ")`, which appears only in `avo-filters`' Gotchas; #18 refused to write DSL and named the missing gem; #19 chose the per-resource approach after checking for `avo-menu`, and `list_icons.rb` caught a hallucinated icon name (`rings-wedding`) before it reached a file. |

### Notes on running it

`claude -p` denies Bash by default, so a run without `--allowedTools "Bash,Read,Glob,Grep,Skill"` reports every prompt as a miss — the loader triggers, then cannot execute the resolver. That failure is indistinguishable from a real one in the log. The first attempt at this eval lost 11 results to it.

Trigger and false-trigger rates are mechanical and can be automated. **Prior-conflict cannot**: it asks whether the produced diff followed the shipped instructions or the model's priors, which needs someone reading the output who is not the author of the skill.

**The legacy `avo-hq/skills` catalog must not be removed until this table has a passing row.** Removing it is the irreversible step, and this is the only evidence that bears on whether the replacement works.
