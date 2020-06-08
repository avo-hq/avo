FROM ruby:2.5

RUN apt-get update -qq && apt-get install -yqq build-essential apt-transport-https apt-utils

# Cache nokogiri
RUN apt-get install -yqq libxml2-dev libxslt1-dev build-essential patch ruby-dev zlib1g-dev liblzma-dev
RUN gem install nokogiri

# Cache selenium-webdriver
RUN gem install selenium-webdriver

# node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y yarn

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install bundler -v 2.1.4

ENV RAILS_ENV=production
ENV NODE_ENV=production

WORKDIR /avocado/

# gems
COPY Gemfile* /avocado/
COPY Rakefile /avocado/
COPY avocado.gemspec /avocado/
COPY package.json /avocado/
COPY ./lib/ /avocado/lib/
RUN bundle install --jobs 4 --retry 3

COPY yarn.lock /avocado/

RUN yarn install
RUN yarn check --integrity

COPY . /avocado/

RUN bin/webpack

RUN ls -la /avocado/public/avocado-packs/
RUN bin/rails build
