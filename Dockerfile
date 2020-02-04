FROM ruby:2.4.0
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler --version=1.17.3
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
RUN echo "kahoi kahoi"
RUN echo $POSTGRES_USER
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
RUN spring stop
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]