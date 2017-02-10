#!/bin/bash

# check OS version
sudo apt-get update && sudo apt-get install -y lsb-release
OS=$(lsb_release -si)
OS=$(echo "${OS,,}")
if [ $OS != "ubuntu" ]
  then
    printf "OS version should be Ubuntu.\nInstallation of POC web server will be terminated!\n"
    exit 1
fi

# environment setup
sudo apt-get -y upgrade && sudo apt-get autoclean && sudo apt-get -y autoremove

# install custom tools
sudo apt-get update && sudo apt-get install -y vim lsb-release net-tools curl

# install MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 123456'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 123456'
sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-client libmysqlclient-dev

# install Gem dependencies for our web APP
sudo apt-get install -y cmake pkg-config libicu-dev libsqlite3-dev

# install Ruby
sudo apt-get install -y software-properties-common python-software-properties
sudo apt-add-repository ppa:brightbox/ruby-ng -y
sudo apt-get update && sudo apt-get install -y ruby2.3 ruby2.3-dev

# install gem
sudo apt-get install -y rubygems

# install bundler
sudo gem install bundler

# install Rails
sudo gem install rails -v 4.2.5.1

# install NginX
sudo apt-get install -y nginx

# install passenger
CODE_NAME=$(lsb_release -sc)
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates
sudo sh -c "echo deb https://oss-binaries.phusionpassenger.com/apt/passenger $CODE_NAME main > /etc/apt/sources.list.d/passenger.list"
sudo apt-get update
sudo apt-get install -y nginx-extras passenger

# configure NginX with Passenger
sudo sed -i '/include \/etc\/nginx\/sites-enabled/a include /etc/nginx/passenger.conf;' /etc/nginx/nginx.conf

# starts all required services
sudo service mysql start
sudo service nginx restart
