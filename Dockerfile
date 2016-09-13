FROM ruby:2.3.1

RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev mysql-client --fix-missing --no-install-recommends

ENV INSTALL_PATH /cloudtown

RUN mkdir -p $INSTALL_PATH

WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install
# foreman doesn't want to be part of Gemfile

# Copy in the application code from your work station at the current directory
# over to the working directory.
ADD . $INSTALL_PATH
WORKDIR $INSTALL_PATH

# Provide dummy data to Rails so it can pre-compile assets.
RUN RAILS_ENV=production DATABASE_URL=mysql2://user:pass@127.0.0.1/dbname SECRET_TOKEN=2j30923u0239u3joweicnansoonlciw08fhlaihcoufgjgwql02idjnut bundle exec rake assets:precompile --trace

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# The default command that gets ran will be to start the Unicorn server.
ENV RAILS_ENV staging
EXPOSE 9292
CMD bundle exec puma
