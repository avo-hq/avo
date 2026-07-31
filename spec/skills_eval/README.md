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
| _not yet run_ | | | | | |

**The legacy `avo-hq/skills` catalog must not be removed until this table has a passing row.** Removing it is the irreversible step, and this is the only evidence that bears on whether the replacement works.
