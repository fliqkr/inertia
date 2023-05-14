FROM ruby:3.0.6

RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g yarn

WORKDIR /app/inertia

COPY . .

RUN gem install bundler:2.4.13 && \
	bundle install && \
	npm install

EXPOSE 3000

CMD ["sh", "scripts/production.sh"]
