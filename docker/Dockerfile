FROM ruby:2.6.4

RUN apt-get update -qq && apt-get install -yqq build-essential apt-transport-https apt-utils

# Cache nokogiri
RUN apt-get install -yqq libxml2-dev libxslt1-dev build-essential patch ruby-dev zlib1g-dev liblzma-dev
RUN gem install nokogiri selenium-webdriver ffi ruby-debug-ide tilt

# node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install bundler -v 2.2.5

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLE_WITHOUT=development:test

WORKDIR /avo/

# gems
COPY Gemfile* /avo/
COPY Rakefile /avo/
COPY avo.gemspec /avo/
COPY ./lib/avo.rb /avo/lib/avo.rb
COPY ./lib/avo/version.rb /avo/lib/avo/version.rb
RUN bundle install --jobs 4 --retry 3

COPY package.json /avo/
COPY yarn.lock /avo/

RUN yarn install
RUN yarn check --integrity

COPY ./bin/                        /avo/bin/
COPY ./app/packs/                  /avo/app/packs/
COPY ./config/                     /avo/config/
COPY ./.eslintrc.json              /avo/.eslintrc.json
COPY ./jsconfig.json               /avo/jsconfig.json
COPY ./postcss.config.js           /avo/postcss.config.js
COPY ./tailwind.config.js          /avo/tailwind.config.js
COPY ./babel.config.js             /avo/babel.config.js

# Copy the files needed by PurgeCSS
COPY . /avo/

# Remove webpacker.yml config files
RUN rm /avo/config/webpacker.yml
RUN rm /avo/config/webpacker_packed.yml
# Add a custom development env for the packed version in order to not start the webpacker process when using Avo in your app's development env.
COPY ./config/webpacker_packed.yml /avo/config/webpacker.yml

RUN bin/webpack

RUN bundle exec rails build
