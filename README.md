![Tests](https://github.com/adrianthedev/avocado/workflows/Tests/badge.svg)

# Avocado
The missing Ruby on Rails admin

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'avocado'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install avocado
```

## Testing

We use `rspec` to run our tests. To run unit tests use `npm run test`. For system tests `npm run test-system` and to run them all `npm run test-all` or simply `rspec`

## Contributing

```
git clone
cd avocado
bundle install
bin/rails server
```

You may also use the VSCode launcher to take advantage of the debugger.

You may need to run `rake db:migrate && rake db:test:prepare` for local development.

To start the Webpack dev server you need to have a different seesion running `bin/webpack-dev-server`.

## License
Commercial license

## Building & Releasing

If you just need a quick development build of the gem, just run `rails build`.

To build for **release** (production mode), you need to run `yarn build`. This will build a docker image that will build the gem using `production` env variables. At the end of the process it will place the new gem under `pkg/` directory.

To release the gem, run `yarn release`. This will increment the version name, cut a tag and push to GitHub. From there, GitHub Actions will take over to build the artifact, create a release and add the artifact to that release.

TODO: Add automatic release notes from previous commits to release.
