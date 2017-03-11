FROM ruby:2.4.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /bar-manager
WORKDIR /bar-manager
ADD Gemfile /bar-manager/Gemfile
ADD Gemfile.lock /bar-manager/Gemfile.lock
ADD config/environments/development.rb /bar-manager/config/environments/development.rb
RUN bundle install
ADD . /bar-manager