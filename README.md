![Tests](https://github.com/avo-hq/avo/workflows/Tests/badge.svg)
![reviewdog](https://github.com/avo-hq/avo/workflows/reviewdog/badge.svg)
[![codecov](https://codecov.io/gh/avo-hq/avo/branch/master/graph/badge.svg?token=Q2LMFE4989)](https://codecov.io/gh/avo-hq/avo)
[![Maintainability](https://api.codeclimate.com/v1/badges/676a0afa2cc79f03aa29/maintainability)](https://codeclimate.com/github/avo-hq/avo/maintainability)

![](https://avohq.io/img/logo-full-stroke-tiny-2x.png)

**Configuration-based, no-maintenance, extendable Ruby on Rails admin**

Avo is a beautiful next-generation framework that empowers you, the developer, to create fantastic admin panels for your Ruby on Rails apps with the flexibility to fit your needs as you grow.

## Get started

**Website**: [avohq.io](https://avohq.io)\
**Documentation**: [docs.avohq.io](https://docs.avohq.io)\
**Twitter**: [avo_hq](https://twitter.com/avo_hq)\
**Community chat**: [discord](https://discord.gg/pkTF6y8)\
**Issue tracker**: [GitHub issues](http://github.com/avo-hq/avo/issues)

## Features

  - **Code driven configuration** - Configure your Rails dashboard entirely by writing Ruby code.
  - **Resource Management** - Create a CRUD interface for Active Record from one command. No more copy-pasting view and controller files around.
  - **Active Storage support** - Amazingly easy, **one-line**, single or multi-file integration with **ActiveStorage**.
  - **Grid view** - Beautiful card layout to showcase your content.
  - **Actions** - Run custom actions to one or more of your resources with as little as pressing a button 💪
  - **Filters** - Write your own custom filters to quickly segment your data.
  - **Keeps your app clean** - You don't need to change your app to use Avo. Drop it in your existing app or add it to a new one and you're done 🙌
  - **Custom fields***- No worries if we missed a field you need. Generate a custom field in a jiffy.
  - **Dashboard widgets and metrics*** - Customize your dashboard with the tools and analytics you need.
  - **Custom tools*** - You need to add a page with something completely new, you've got it!
  - **Authorization** - Leverage Pundit policies to build a robust and scalable authorization system.
  - **Themable*** - Dress it up into your own colors.
  - **Localization*** - Have it available in any language you need.

  *Some features are still under development

# Installation
Add this line to your application's `Gemfile`:

```ruby
gem 'avo'
```

And then execute:
```bash
$ bundle install
```

# Contributing

If you happened to come accross a bug or want to suggest a feature, feel free to [say something](https://github.com/avo-hq/avo/issues/new)! 

If you'd like to contribute code, the steps below will help you to get up and running.

## Forking & branches

Please fork Avo and create a descriptive branch for your feature or fix.

## Getting your local environment set up

NOTE: We're using `docker-compose` to run Postres. While we find this incredibly helpful, it's not a requirement, but you'll have to BYOD (Bring Your Own Database).

Once you pull the code down to your machine, running `bin/init` will get you up-and-running.

## Running the Database

If you chose to continue with Docker, you'll be able to run it with one of the following commands:

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
