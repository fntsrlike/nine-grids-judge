#!/bin/bash

if [[ $1 == '-h' ]]; then
	printf "deploy.sh [options] \n\t-h for help\n\t-y for non-checking mode\n\t-d DOMAIN-NAME\n\t-q NINE-GRIDS-QUESTION-FILE\n"
	exit
fi

YES=false
DOMAIN_NAME=false
NINE_GRIDS_QUESTION_FILE=false

while test $# -gt 0
do
	case "$1" in
		-y ) YES=true ;;
		-d ) DOMAIN_NAME=$2 ;;
		-q ) NINE_GRIDS_QUESTION_FILE=$2 ;;
	esac
	shift
done

if ! $YES; then
	echo "Please make sure you're at the root directory of Nine-Grids APP. Press [Enter] to continue and [Ctrl+C] to cancel."
	read -s -n 1 key
	if [[ $key != "" ]]; then
		echo "Invalid key. Abort installation."
		exit
	fi
fi

if [[ $DOMAIN_NAME == false || $DOMAIN_NAME == '' ]]; then
	read -p "Please enter the domain name of your server: " DOMAIN_NAME
	if [[ $DOMAIN_NAME == '' ]]; then
		echo 'Domain name not set. Please manually set your domain name to "/etc/nginx/sites-available/default" later.'
	fi
fi

if [[ $NINE_GRIDS_QUESTION_FILE == false || $NINE_GRIDS_QUESTION_FILE == '' ]]; then
	read -p "Where is the question SQL backup file of Nine-Grids: " NINE_GRIDS_QUESTION_FILE
	if [[ $NINE_GRIDS_QUESTION_FILE == '' ]]; then
		echo 'Nine-Grids question SQL backup file not provided, no auto-question-preparation action will be taken.'
	fi
fi

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

# prepare to build web APP
RUBY_PATH=$(which ruby)
APP_ROOT="$(pwd)/public"

DIR_CHAIN=$APP_ROOT
while [[ $DIR_CHAIN != "/" ]]; do
	sudo chmod o+x $DIR_CHAIN;
	DIR_CHAIN=$(dirname $DIR_CHAIN);
done

# configure NginX virtual host for Nine-Grids APP
sudo printf "server {\n	listen 80 default_server;\n	listen [::]:80 default_server;\n\n	root $APP_ROOT;\n\n	server_name $DOMAIN_NAME;\n\n	passenger_enabled on;\n	passenger_friendly_error_pages on;\n	passenger_ruby $RUBY_PATH;\n}\n" > /etc/nginx/sites-available/default

# build APP
bundle
sudo cp -p .env.sample .env
sudo echo '# Basic Files' >> .env
sudo echo 'COURSE_NAME = "Compiler"' >> .env
sudo printf "\n" >> .env
sudo echo '# Mailer (OO Lab SMTP)' >> .env
sudo echo 'SMTP_FROM = compiler@csie.ncu.edu.tw' >> .env
sudo echo 'SMTP_USERNAME = ncuoolab@gmail.com' >> .env
sudo echo 'SMTP_PASSWORD = rpfmbnvrvpiqjcni' >> .env
sudo printf "\n" >> .env
sudo echo '# Production DB Setting' >> .env
sudo echo 'DB_DATABASE = nine_grids' >> .env
sudo echo 'DB_USERNAME = root' >> .env
sudo echo 'DB_PASSWORD = 123456' >> .env
sudo echo 'DB_HOST = 127.0.0.1' >> .env
sudo echo 'DB_PORT = 3306' >> .env
sudo printf "\n" >> .env
sudo echo '# System Setting' >> .env
sudo echo "SECRET_KEY_BASE = $(RAILS_ENV=production bundle exec rake secret)" >> .env
sudo printf "\n" >> .env

sudo service mysql start

bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=development bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile

if [[ $NINE_GRIDS_QUESTION_FILE != '' ]]; then
	mysql -u root -p123456 nine_grids < $NINE_GRIDS_QUESTION_FILE
fi

RAILS_ENV=production bundle exec rake user:basic
RAILS_ENV=production bundle exec rake db:sessions:clear

sudo service nginx restart
