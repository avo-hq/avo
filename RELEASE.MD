# Release schedule

A new Avo version is released every four-ish weeks, usually on Tuesday. The versioning scheme does not follow semver but a series release.

The current series is series 3 (version `3.1`, `3.2`, `3.9`, etc). Every second Tuesday of the month we'll increment the minor version number (from `3.7` to `3.8`).

## Patch releases

In-between that release cycle we might release patches (`3.7.1` or `3.9.5`) that address particular bugs or issues that are more urgent and can't wait for the next release cycle.

## Pre-releases

Sometimes we publish pre-releases (`3.7.1.pre.1` or `3.5.2.pre.7`).

The pre-releases are usually built on our machines and will be builds from a specific branch, so they don't follow any particular convention. The `pre.2` might contain a fix, but the `pre.3` might not contain that fix because they might be built from different branches. We usually mention on a PR or issue to the bug reporter if they should or shouldn't use pre-releases. They won't get installed in regular `bundle update avo` commands, unless you specify it in the `Gemfile`.
