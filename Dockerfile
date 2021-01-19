FROM ruby:2.7

ARG USER_ID
ARG GROUP_ID

RUN groupadd -o -g $GROUP_ID -r user
RUN useradd -u $USER_ID -g $GROUP_ID user

ENV INSTALL_PATH=/opt/app
RUN mkdir -p $INSTALL_PATH

# nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg -o /root/yarn-pubkey.gpg && apt-key add /root/yarn-pubkey.gpg
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y --no-install-recommends nodejs yarn

# rails
RUN gem install rails bundle
COPY rails_demo/Gemfile Gemfile
WORKDIR /opt/app/rails_demo
RUN bundle install

RUN chown -R user:user /opt/app
USER $USER_ID
VOLUME ["$INSTALL_PATH/public"]
CMD bundle exec unicorn -c config/unicorn.rb
