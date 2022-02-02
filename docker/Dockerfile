FROM ruby:3.1.0

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

RUN gem install bundler -v 2.2.32

ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLE_WITHOUT=development:test

WORKDIR /avo/

# Install gems
COPY Gemfile /avo/Gemfile
COPY Rakefile /avo/
COPY avo.gemspec /avo/
COPY ./lib/avo.rb /avo/lib/avo.rb
RUN mkdir /avo/lib/avo

# Cache the bundle install command with a fake version
COPY ./tmp/Gemfile_v1.lock /avo/Gemfile.lock
COPY ./tmp/version_v1.rb /avo/lib/avo/version.rb
RUN bundle install --jobs 4 --retry 3

COPY package.json /avo/
COPY yarn.lock /avo/

RUN yarn install
RUN yarn check --integrity

# re-run bundle install with the appropriate version number
COPY ./lib/avo/version.rb /avo/lib/avo/version.rb
RUN bundle install --jobs 4 --retry 3

# Copy the files
COPY . /avo

RUN yarn prod:build
RUN yarn prod:build:css

RUN bundle exec rails build
