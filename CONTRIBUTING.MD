# Contributing

First of all, thank you for considering fixing or improving Avo. This is a community project, and all your contributions are most welcomed.

If you came across a bug or want to suggest a feature, feel free to [say something](https://github.com/avo-hq/avo/issues/new)!

If you'd like to contribute code, the steps below will help you get up and running.

## Elements naming

`Resource` or `@resource` is an instantiated `Avo::Resource` object.

`resource_name`: Pluralized, machine name, snake-cased version of a resource. Ex: `resource_name` for `/avo/resources/team_memberships` path is going to be `TeamMemberships`.

`Model` or `@model`: Active Record `Model` object.

Since v `1.20` (Jan 2022), we started to change the `model` name with `record` where it fits. So the `model` should be the class (ex: `User`, `Comment`, etc.), and `record` will be the instantiated model class with data (ex: `user` is a record when doing `user = User.find(1)`).

## Forking & branches

Please fork Avo and create a descriptive branch for your feature or fix. We usually use the `feature/`, `chore/`, or `fix/` branch prefixes. This way, the PR gets automatically labeled.

## Contributing with Pull Requests

Thank you for considering to contribute to Avo. These are our recommendations to improve readability and interoperability when contributing with a PR:

- the title should have the type (`feature`, `chore`, `fix`, `refactor`) followed by the sentence case of what it does (ex: `feature: scoped search for has many associations` or `fix: broken sidebar on desktop`).
- the PR should be marked by the appropiate tag (`feature`, `chore`, `fix`, `refactor`)
- if there's an issue open that could be fixed by this PR you can mark it by writing `Fixes ISSUE_URL` in the description so GitHub automates some actions (ex: `Fixes https://github.com/avo-hq/avo/issues/1008`). If there are more issues that could be fixed, add more lines.
- please follow the steps on the `Checklist` and mark them as done with an `x` inside the brackets `[x]`
- if there's something that we can test, please send us the instructions to do that in that PR description.
- ask for help navigating the codebase. We love it when you do!
- enjoy the process and the thing you are making, fixing, or improving.

Thank you!

## Getting your local environment set up

NOTE: We're using our local Postgres instance.

You may use docker with the provided `docker-compose.yml` file.

Once you pull the code down to your machine, modify `spec/dummy/config/database.yml` as appropriate to your environment (no changes needed if you're using local Postgres). Do not commit these changes. From here, running `bin/init` will get you up-and-running.

# Local development

## Running the dummy app

You can run `bin/dev` from the root directory, which will start an overmind (similar to foreman) process for the rails server, jsbundling and cssbundling. Then, navigate to `localhost:3030` and enjoy the app.

## Seeding the database for local development

Run `AVO_ADMIN_PASSWORD=secret bin/rails db:seed` to seed the database with dummy data and create a user for yourself with the email `avo@avohq.io` and password `secret`.

## Using your fork from another project

You may want to evaluate your changes in the context of an actual project. Follow these instructions to do so without publishing your own version of the gem.

In the other project, change the `Gemfile` entry for `avo` to point to your local clone of this repo. For example:

```ruby
gem 'avo', path: '../avo'
```

Avo's assets will not show up by default, resulting in 404 errors on `/avo-assets/avo.base.js` and `/avo-assets/avo.base.css`. To avoid this, you need to compile the asset bundles, and symlink them into `public/avo-assets`.

Create symlinks for compiled assets into the `public` directory. You'll only need to do this once.

```bash
# `cd` into the root directory of this project.
ln -sf $(pwd)/app/assets/builds/avo.base.js public/avo-assets/avo.base.js
ln -sf $(pwd)/app/assets/builds/avo.base.css public/avo-assets/avo.base.css
```

After that, you'll need to compile the asset bundles any time you make changes to the JS or CSS code:

```bash
yarn build
```

# Running tests

When running tests, you have two options.

1. running them on your local database
2. to use a database in a docker environment.

Run the migration script `bin/rails db:migrate`. Now you'll be able to run the test scripts below:

## Running tests with local database

Copy the `.env.test.sample` (`cp spec/dummy/.env.test.sample spec/dummy/.env.test`) and update it with the proper credentials for your local database. Run the migration script `bin/rails db:migrate`. Now you'll be able to run the test scripts below:

We've set up a few helpers to get you going:

- Run all tests (slow): `bin/test`
- Run unit tests (fast): `bin/test unit`
- Run system tests (slow): `bin/test system`
- Run a particular spec file/test (fast): `bin/test ./spec/features/hq_spec.rb`

## Running tests using the docker container

You may want to run the tests on your docker container. To do that, update your `.env.test` file with valid credentials for the docker setup like below. We do provide a `docker-compose.yml` file for the testing DB, so you can do `docker compose up`, but that's not our preferred method, and you might need to do some tweaks. You'll then be able to run the migration script and the testing commands.

```
POSTGRES_HOST=localhost
POSTGRES_PORT=5433
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=
```

## Test helpers

### Saving a record

If before we'd use something manual like `click_on "Save"` and follow it with a `wait_for_loaded` to make sure the page navigation happened, we can use the `save` helper.

### Stub the resource with fields

Ideally, you'd want to test a field with multiple configurations. For example, test the `time` field once with `relative: true` and then with `relative: false`.
You may do that using the `RESOURCE_CLASS.with_temporary_items` method.

```ruby
RSpec.describe "Time field", type: :system do
  after do
    CourseResource.restore_items_from_backup
  end

  describe "relative: false"
    before do
      CourseResource.with_temporary_items do
        field :starting_at, as: :time, relative: false
      end
    end
    it { tests_something_with_relative_false }
  end

  describe "relative: true"
    before do
      CourseResource.with_temporary_items do
        field :starting_at, as: :time, relative: true
      end
    end
    it { tests_something_with_relative_true }
  end
end
```

In order to restore the previous fields you may run `RESOURCE_CLASS.restore_items_from_backup` after the test.

### Working with datepickers

The prerequisite for these helpers is to ensure you have the two inputs mapped in your test file like so and you update the `FIELD_ID` attribute to the field you decalred on your resource `created_at`, `starting_at`, etc.

```ruby
subject(:text_input) { find '[data-field-id="FIELD_ID"] [data-controller="date-field"] input[type="text"]' }
```

Then you may use the `open_picker`, `close_picker`, `set_picker_day`, `set_picker_hour`, `set_picker_minute`, `set_picker_second` like so:

```ruby
open_picker
close_picker
set_picker_day "January 2, 2000"
set_picker_hour 17
set_picker_minute 17
set_picker_second 17
```

### Working with timezones

You may want to spoof the timezone for a test. you may use the `tz` helper.

```ruby
describe "something", tz: "America/Los_Angeles" do
  # run your test here
end
```

When running system tests you need to reset the browser in order to have it read the newly declared timezone. To do that use the `reset_browser` helper.
Unfortunately, that helper does not work as expected in the `before`, `after`, or `around` hooks and you must manually call them at the beginning of a suite.

```ruby
describe "something", tz: "America/Los_Angeles"do
  it { reset_browser }
end
```

# Release details

## Update appraisal gemfiles

We use [appraisal](https://github.com/thoughtbot/appraisal) to run tests against multiple versions of Rails. When the gemfile gets updated, you must also run `bundle exec appraisal install` to update the versioned ones and commit them to the repo.

Please read the [RELEASE.MD](./RELEASE.MD) for release schedules.

# Custom JS

To test the custom Stimulus integration, we need to have some JS content injected into the dummy app. We also need not to have that content present in every Avo installation. That's why we ejected the `_head.html.erb` partial that loads the `avo_custom.js` file from the engine's `build` directory. The build directory is not committed to git, so we're all good on that. To have that file built and watched, we use a `cjs` (short for `custom-js`) process in the `Procfile.dev` (used only in development).

# Misc

## Annotate models

To keep track of the schema structure for the models, run `annotate --models --exclude fixtures` in the dummy app.

## Using VSCode?

We compiled [an extension pack](https://marketplace.visualstudio.com/items?itemName=adrianthedev.vsruby) with a few extensions that should help you with Ruby development. We use them with Avo.
