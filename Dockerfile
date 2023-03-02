FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

# set shell options (see documentation for more details)
RUN set -eux

RUN apt-get update --fix-missing
RUN apt-get install -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y

RUN apt-get install -y apache2 sendmail
RUN apt-get install -y php7.4 libapache2-mod-php7.4 php7.4-cli php7.4-common php7.4-mbstring php7.4-gd php7.4-intl php7.4-xml php7.4-mysql php7.4-mcrypt php7.4-zip

RUN php -v
# enable Apache2 rewrite module
RUN a2enmod rewrite

# composer needs
RUN echo "Y" | apt-get install curl
RUN echo "Y" | apt-get install git
RUN echo "Y" | apt-get install zip unzip

# composer installation
RUN cd /tmp && curl -sS https://getcomposer.org/installer | php
RUN cd /tmp && mv composer.phar /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

# memcached
# RUN apt-get install -y php-memcached memcached

# set the work directory to /var/www/html (this is the webroot)
# when someone connects, this will be the starting-point
COPY . /var/www/html
WORKDIR /var/www/html

# copy the customized Apache2 vhost file from the project to the image

COPY ./000-default.conf /etc/apache2/sites-available/

# move the custom settings
RUN ls -la
RUN ls -la /var/www/html/
RUN mv ./settings.php /var/www/html/web/sites/default/settings.php

# Install Composer dependencies
RUN composer config --no-plugins allow-plugins.drupal/core-composer-scaffold true ## LEV
RUN composer config --no-plugins allow-plugins.drupal/core-project-message true ## LEV
RUN composer install --no-dev && composer clear-cache

# Install Drush
ENV DRUSH_VERSION 8.1.2
RUN curl -L --silent https://github.com/drush-ops/drush/releases/download/${DRUSH_VERSION}/drush.phar \
  > /usr/local/bin/drush && chmod +x /usr/local/bin/drush

# fix warning : Could not reliably determine the server's fully qualified domain name ...
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# allow read & write access
RUN chmod 755 -R /var/www/html/web/sites/default
RUN chmod 755 /var/www/html/web/sites/default/settings.php
RUN chown www-data:www-data /var/www/html/web/sites/default/ -R

# copy the custom startup-script into the image
RUN mv docker_entrypoint.sh /usr/local/bin/docker_entrypoint
RUN chmod +x /usr/local/bin/docker_entrypoint
RUN chmod 744 /usr/local/bin/docker_entrypoint

CMD ["docker_entrypoint"]
