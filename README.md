[![Gem Version](https://badge.fury.io/rb/avo.svg)](https://badge.fury.io/rb/avo)
[![System Tests](https://github.com/avo-hq/avo/actions/workflows/system-tests.yml/badge.svg)](https://github.com/avo-hq/avo/actions/workflows/system-tests.yml)
[![Feature Tests](https://github.com/avo-hq/avo/actions/workflows/feature-tests.yml/badge.svg)](https://github.com/avo-hq/avo/actions/workflows/feature-tests.yml)
[![Lint](https://github.com/avo-hq/avo/actions/workflows/lint.yml/badge.svg)](https://github.com/avo-hq/avo/actions/workflows/lint.yml)
<a href="https://github.com/avo-hq/avo/discussions" target="_blank">
  <img alt="GitHub Discussions" src="https://img.shields.io/github/discussions/avo-hq/avo?color=168AFE&logo=github">
</a>
<a href="https://github.com/avo-hq/avo/issues" target="_blank">
  <img alt="GitHub Issues or Pull Requests" src="https://img.shields.io/github/issues-closed/avo-hq/avo?style=flat&link=https%3A%2F%2Fgithub.com%2Favo-hq%2Favo%2Fissues&logo=github">
</a>
<a href="https://rubygems.org/gems/avo">
  <img alt="GEM Downloads" src="https://img.shields.io/gem/dt/avo?color=168AFE&logo=ruby&logoColor=FE1616">
</a>
<a href="https://github.com/testdouble/standard">
  <img alt="Ruby Style" src="https://img.shields.io/badge/style-standard-168AFE?logo=ruby&logoColor=FE1616" />
</a>
[![codecov](https://codecov.io/gh/avo-hq/avo/branch/master/graph/badge.svg?token=Q2LMFE4989)](https://codecov.io/gh/avo-hq/avo)
[![Maintainability](https://api.codeclimate.com/v1/badges/676a0afa2cc79f03aa29/maintainability)](https://codeclimate.com/github/avo-hq/avo/maintainability)

![](./public/avo-assets/logo-on-white.png)

**<a href="https://avohq.io" title="Ruby on Rails Admin Panel Framework">Avo - Ruby on Rails Admin Panel Framework</a>**

Avo is a very custom Admin Panel Framework, Content Management System, and Internal Tool Builder for Ruby on Rails that saves engineers and teams **months of development time**.

## Get started

⚡️ **Install**: [docs.avohq.io/3.0/installation](https://docs.avohq.io/3.0/installation.html)
<br>
✨ **Website**: [avohq.io](https://avohq.io)
<br>
📚 **Documentation**: [docs.avohq.io](https://docs.avohq.io)
<br>
🗺 **Roadmap**: [GitHub Roadmap](https://github.com/orgs/avo-hq/projects/14)
<br>
🎸 **Demo App**: [Avodemo](https://main.avodemo.com/)
<br>
🐤 **Twitter**: [`avo_hq`](https://twitter.com/avo_hq)
<br>
🔧 **Issue Tracker**: [GitHub Issues](http://github.com/avo-hq/avo/issues)
<br>
🎙 **Discussions and Feature Requests**: [GitHub Discussions](http://github.com/avo-hq/avo/discussions)

## Features

  - **Powered by Hotwire** - Rails ❤️  Hotwire
  - **Code driven configuration** - Configure your Rails dashboard entirely by writing Ruby code. [docs](https://docs.avohq.io/3.0/resources.html#defining-resources)
  - **Resource Management** - Create a CRUD interface for Active Record from one command. No more copy-pasting view and controller files around.
  - **Dashboard widgets and metrics** - Create metrics, charts, and custom cards amazingly fast. [docs](https://docs.avohq.io/3.0/dashboards.html)
  - **Resource Search** - Quickly run a search through one or more resources at once. [docs](https://docs.avohq.io/3.0/search.html)
  - **Associations enabled** - Link your models together with all types of associations (belongs_to, has_many, polymorphic, etc.). [docs](https://docs.avohq.io/3.0/associations.html)
  - **Fuzzy-searchable associations** - Do you have a ton of records and don't want to scroll through a big dropdown? Avo's got you covered. [docs](https://docs.avohq.io/3.0/associations/belongs_to.html#searchable)
  - **Active Storage support** - Amazingly easy, **one-line**, single or multi-file integration with **ActiveStorage**. [docs](https://docs.avohq.io/3.0/fields/file.html)
  - **Records Ordering** - Sorting records is a breeze. [docs](https://docs.avohq.io/3.0/records-reordering.html)
  - **Grid view** - Beautiful card layout to showcase your content. [docs](https://docs.avohq.io/3.0/grid-view.html)
  - **Actions** - Run custom actions to one or more of your resources with as little as pressing a button 💪 &nbsp; [docs](https://docs.avohq.io/3.0/actions.html)
  - **Filters** - Write your own custom filters to quickly segment your data. [docs](https://docs.avohq.io/3.0/filters.html)
  - **Keeps your app clean** - You don't need to change your app to use Avo. Drop it in your existing app or add it to a new one and you're done 🙌 [docs](https://docs.avohq.io/3.0/installation.html)
  - **Custom fields**- No worries if we missed a field you need. Generate a custom field in a jiffy. [docs](https://docs.avohq.io/3.0/custom-fields.html)
  - **Custom tools** - Break out of the CRUD. Do you need to add a page with something completely new? You've got it! [docs](https://docs.avohq.io/3.0/custom-tools.html)
  - **Authorization** - Leverage Pundit policies to build a robust and scalable authorization system. [docs](https://docs.avohq.io/3.0/authorization.html)
  - **Localization** - Have it available in any language you need. [docs](https://docs.avohq.io/3.0/localization.html)
  - **No asset pipeline pollution** - Bring your own asset pipeline. [docs](https://docs.avohq.io/3.0/custom-asset-pipeline.html)
  - **Mobile interface** - Check your data on the go from any mobile device.
  - **Tabbed interface** - Conditionally show the data you need
  - **Menu builder** - Group and surface information as you need to
  - **Branding** - Make it look

## Some of the things we're going to focus on next

Theming ⭐️  &nbsp;notifications ⭐️  &nbsp;Resource segmentation ⭐️  &nbsp;inline editing ⭐️  &nbsp;multilingual records ⭐️  &nbsp;keyboard shortcuts ⭐️  &nbsp;track resource changes ⭐️  &nbsp;live resources ⭐️  &nbsp;columns view ⭐️  &nbsp;list view ⭐️  &nbsp;custom action items ⭐️  &nbsp;command bar

For more up-to-date info check out our 🗺 [Roadmap](https://github.com/orgs/avo-hq/projects/14).

# Installation

Use this RailsBytes template to get started quick `rails app:template LOCATION='https://avohq.io/app-template'`. If you need a more detailed guide, follow [this page](https://docs.avohq.io/3.0/installation.html).

# Contributing

Please read [CONTRIBUTING.MD](./CONTRIBUTING.MD)

# Upgrade Guide

Please read the [UPGRADE_GUIDE.MD](https://docs.avohq.io/3.0/upgrade.html)

# Release schedule

Please read the [RELEASE.MD](./RELEASE.MD)

# ✨ [Contributors](https://avohq.io/contributors)

<a href="https://avohq.io/contributors">
  <img src="https://contrib.rocks/image?repo=avo-hq/avo" />
</a>
<!--  https://contrib.rocks -->

# 🥇 Sponsors

<table>
<tr>
  <td>
    <a href="https://www.greenhats.com/?utm_source=github&utm_medium=link&utm_campaign=avo" target="_blank">
      <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://avohq.io/img/sponsors/greenhats-dark.png">
        <img alt="Greenhats Start-up Sponsor" src="https://avohq.io/img/sponsors/greenhats-light.png" width="360px">
      </picture>
    </a>
  </td>
</tr>
</table>

[Become a sponsor ](https://github.com/sponsors/adrianthedev)


![Alt](https://repobeats.axiom.co/api/embed/1481a6a259064f02a7936470d12a50802a9c98a4.svg "Repobeats analytics image")

# Shoutouts

[Get a box of waffles and some of the best app monitoring from Appsignal](https://appsignal.com/r/93dbe69bfb) 🧇

[Get $100 in credits from Digital Ocean](https://www.digitalocean.com/?refcode=efc1fe881d74&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge) 💸
