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

#memcached
RUN apt-get install -y php-memcached memcached

# set the work directory to /var/www/html (this is the webroot)
# when someone connects, this will be the starting-point
COPY . /var/www/html
WORKDIR /var/www/html

# copy the customized Apache2 vhost file from the project to the image
COPY ./docker/000-default.conf /etc/apache2/sites-available/

# copy the custom startup-script into the image
COPY ./docker/startup-script.sh /usr/local/bin/startup-script
RUN chmod +x /usr/local/bin/startup-script
RUN chmod 744 /usr/local/bin/startup-script

# Install Composer dependencies
RUN cd /var/www/html && composer install --no-dev && composer clear-cache

# Install Drush
ENV DRUSH_VERSION 8.1.2
RUN curl -L --silent https://github.com/drush-ops/drush/releases/download/${DRUSH_VERSION}/drush.phar \
  > /usr/local/bin/drush && chmod +x /usr/local/bin/drush

# fix warning : Could not reliably determine the server's fully qualified domain name ...
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# allow read & write access
RUN chmod 755 -R /var/www/html/sites/default
RUN chmod 755 /var/www/html/sites/default/settings.php
RUN chown www-data:www-data /var/www/html/sites/default/ -R


CMD ["startup-script"]
