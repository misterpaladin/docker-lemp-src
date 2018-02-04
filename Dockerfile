FROM ubuntu:16.04
MAINTAINER Min De Sik <ds@codesmith.ru>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install -y sudo nano wget curl openssh-client zip apt-transport-https

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y language-pack-en-base &&\
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y
RUN apt-get install -y --allow-unauthenticated nginx php7.1-fpm php7.1-mbstring php7.1-memcached php7.1-mcrypt php7.1-gd php7.1-sqlite php7.1-xdebug php7.1-json php7.1-mysqlnd php7.1-pdo-pgsql php7.1-curl php7.1-xml php7.1-bcmath php7.1-imagick ruby ruby-dev make gcc build-essential
RUN gem install jekyll bundler

RUN echo "www-data ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm composer-setup.php
RUN wget https://phar.phpunit.de/phpunit-library-5.3.5.phar && mv phpunit-library-5.3.5.phar /usr/local/bin/phpunit && chmod +x /usr/local/bin/phpunit

WORKDIR /srv

RUN apt-get install -y git
RUN wget https://nodejs.org/dist/v8.9.4/node-v8.9.4-linux-x64.tar.gz
RUN tar -C /usr/local --strip-components 1 -xzf node-v8.9.4-linux-x64.tar.gz
RUN rm node-v8.9.4-linux-x64.tar.gz
RUN npm -g install gulp-cli
RUN npm -g install coffee-script
RUN npm -g install bower
RUN apt-get install yarn -y
RUN phpdismod xdebug

COPY ./scripts/serve.sh /usr/local/bin/serve
RUN chmod +x /usr/local/bin/serve

EXPOSE 80 8000 443
CMD service nginx start && service php7.1-fpm start && tail -F /var/log/nginx/*