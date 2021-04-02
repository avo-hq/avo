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

- Host: `PGHOST` (Default: `localhost`)
- Port: `PGPORT` (Default: `5433`)
- Username: `PGUSERNAME` (Default:`postgres`)
- Password: `PGPASSWORD` (Default:`nil`)

## Running tests

We've set up a few helpers to get you going:

- Run all tests (slow): `bin/test`
- Run unit tests (fast): `bin/test unit`
- Run system tests (slow): `bin/test system`
- Run a particular spec file/test (fast): `bin/test ./spec/features/hq_spec.rb:10`

## Seeding the database

Run `AVO_ADMIN_PASSWORD=secret bin/rails db:seed` to seed the database with dummy data and create a user for yourself with the email `admin@avohq.io` and password `secret`.
