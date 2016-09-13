FROM ruby:2.3.1

RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev mysql-client --fix-missing --no-install-recommends

ENV INSTALL_PATH /cloudtown

RUN mkdir -p $INSTALL_PATH

# this seemingly illogical stanza is a way to allow the container to keep a
# cached copy of Gemfile and the bundle, so it can be cached between builds
# unless there is a change.
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install

# Copy in the application code from your work station at the current directory
# over to the working directory.
ADD . $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Provide dummy data to Rails so it can pre-compile assets.
RUN RAILS_ENV=production DATABASE_URL=mysql2://user:pass@127.0.0.1/dbname SECRET_TOKEN=10f0000bad1dea bundle exec rake assets:precompile --trace

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# The default command that gets ran will be to start the app server.
ENV RAILS_ENV staging
EXPOSE 9292
CMD bundle exec puma
