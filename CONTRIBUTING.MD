# Contributing

If you happened to come across a bug or want to suggest a feature, feel free to [say something](https://github.com/avo-hq/avo/issues/new)!

If you'd like to contribute code, the steps below will help you get up and running.

## Elements naming

`Resource` or `@resource` is an instantiated `Avo::Resource` object.

`resource_name`: Pluralized, machine name, snake cased version of a resource. Ex: `resource_name` for `/avo/resources/team_memberships` path is going to be `TeamMemberships`.

`Model` or `@model`: Active Record `Model` object.

## Forking & branches

Please fork Avo and create a descriptive branch for your feature or fix.

## Getting your local environment set up

NOTE: We're using `docker-compose` to run Postgres. While we find this incredibly helpful, it's not a requirement, but you'll have to BYOD (Bring Your Own Database).

Once you pull the code down to your machine, running `bin/init` will get you up-and-running.

## Running the Database

If you chose to continue with Docker, you'd be able to run it with one of the following commands:

- Run in the foreground: `docker-compose up`
- Run in the background: `docker-compose up -d`

If you chose to run your own database, if need be, you'll be able to set the following environment variables:

- Host: `POSTGRES_HOST` (Default: `localhost`)
- Port: `POSTGRES_PORT` (Default: `5433`)
- Username: `POSTGRES_USERNAME` (Default:`postgres`)
- Password: `POSTGRES_PASSWORD` (Default:`nil`)

### Initialize the Database

Make sure you setup the database by running `RAILS_ENV=test bin/rails db:setup` and have the latest migrations on the database layer too by running `RAILS_ENV=test bin/rails db:migrate`. This creates the database and applies the migrations to the docker container that holds the database.

## Running tests

When running tests you have two options. Running on your local database or to use a database in a docker environment.

Copy the `.env.test.sample` (`cp spec/dummy/.env.test.sample spec/dummy/.env.test`) and update it with the proper credentials for your local database.

Run the migration script `bin/rails db:migrate`. Now you'll be able to run the test scripts below:

### Running tests with local database

Copy the `.env.test.sample` (`cp spec/dummy/.env.test.sample spec/dummy/.env.test`) and update it with the proper credentials for your local database. Run the migration script `bin/rails db:migrate`. Now you'll be able to run the test scripts below:

We've set up a few helpers to get you going:

- Run all tests (slow): `bin/test`
- Run unit tests (fast): `bin/test unit`
- Run system tests (slow): `bin/test system`
- Run a particular spec file/test (fast): `bin/test ./spec/features/hq_spec.rb`

### Running tests using the docker container

You may want to run the tests on your docker container. To do that, update your `.env.test` file with valid credentials for the docker setup like below. You'll then be able to run the migration script and the testing commands.

```
POSTGRES_HOST=localhost
POSTGRES_PORT=5433
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=
```

## Seeding the database

Run `AVO_ADMIN_PASSWORD=secret bin/rails db:seed` to seed the database with dummy data and create a user for yourself with the email `admin@avohq.io` and password `secret`.

## Update appraisal gemfiles

We use [appraisal](https://github.com/thoughtbot/appraisal) to run tests against multiple versions of rails. When the gemfile gets updated you must also run `bundle exec appraisal install` to update the versioned ones and commit them to the repo.
