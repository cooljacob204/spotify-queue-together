FROM ruby:3.1.0-alpine

RUN apk add --no-cache --update build-base \
  linux-headers \
  git \
  postgresql-dev \
  nodejs \
  tzdata

RUN gem install bundler

RUN adduser --home /home/rails -s /bin/bash --disabled-password rails
WORKDIR /home/rails

COPY ./Gemfile /home/rails/Gemfile
COPY ./Gemfile.lock /home/rails/Gemfile.lock

RUN bundle install --jobs $(nproc)

COPY . /home/rails

RUN chown -R rails:rails /home/rails

USER rails

CMD [ "rails", "s", "-b", "0.0.0.0" ]