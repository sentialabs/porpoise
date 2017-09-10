# Build with docker build -t porpoise-app .
# Run with docker run -it --rm -v "$PWD:/porpoise" porpoise-app

FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential ruby-dev vim sqlite3

ENV APP_HOME /porpoise
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD . $APP_HOME

RUN gem install rake -v=10.5.0
RUN bundle install

CMD /bin/bash
