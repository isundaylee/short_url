FROM 'ruby:2.6.5-alpine'

# RUN bundle config --global frozen 1

RUN apk add --update \
  build-base \
  git \
  nodejs \
  libxml2-dev \
  libxslt-dev

WORKDIR /usr/src/app

RUN bundle config build.nokogiri -- --use-system-libraries
COPY Gemfile* ./
RUN bundle install

COPY . .

CMD ["rackup", "--host", "0.0.0.0"]
