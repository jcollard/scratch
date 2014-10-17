FROM ubuntu:14.04
MAINTAINER Joseph Collard <josephmcollard@gmail.com>

WORKDIR /root
USER root

RUN apt-get update

RUN apt-get install -y wget


#
# Install Apache
#

RUN apt-get install -y apache2

#
# Install mod_auth_openidc
#

# Dependencies
RUN apt-get install -y libcurl3 libjansson4

#RUN wget https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.3/libapache2-mod-auth-openidc_1.3_amd64.deb
RUN wget https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.5/libapache2-mod-auth-openidc_1.5_amd64.deb
RUN dpkg -i libapache2-mod-auth-openidc_1.5_amd64.deb

#RUN wget https://github.com/pingidentity/mod_auth_openidc/releases/download/v1.6.0/libapache2-mod-auth-openidc_1.6.0-1_amd64.deb
#RUN dpkg -i libapache2-mod-auth-openidc_1.6.0-1_amd64.deb

#
# Configure Apache
#

RUN a2enmod auth_openidc
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod ssl

# Setup Captain Teach Server

# Create User
RUN adduser --disabled-password --gecos "" admiraledu

#
# Install supervisord
#
RUN apt-get install -y supervisor

#######################################################################
# Add captain-teach apache configuration file
# This file specifies how the user is authenticated
# Note: You need to modify this file
#######################################################################
ADD docker/captain-teach.conf /etc/apache2/conf-available/captain-teach.conf
RUN a2enconf captain-teach

##########################################################################
# Add captain-teach-http apache site. This site describes how your server
# should work when it is accessed on port 80
# The default setting is configured to:
#   * Redirect traffic to https://localhost/
##########################################################################
ADD docker/captain-teach-http.conf /etc/apache2/sites-available/captain-teach-http.conf
RUN a2ensite captain-teach-http

#
# Apache fails to start on install since it has unbound variables. That puts
# it into an inconsistent state. The line below cleans up.
#
RUN service apache2 start; service apache2 stop

#
# Configure Supervisor
#
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /var/www/html/test-class/
ADD index.html /var/www/html/test-class/index.html
RUN mkdir /var/www/html/test-class/sub-dir/
ADD index.html /var/www/html/test-class/sub-dir/index.html

CMD supervisord
