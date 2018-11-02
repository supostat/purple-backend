FROM ruby:2.5

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && \
    rm -rf /var/lib/apt/lists/*

ENV INSTALL_PATH /purple
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

ENV GEM_HOME /gems
ENV GEM_PATH /gems
ENV BUNDLE_PATH /gems

COPY . .