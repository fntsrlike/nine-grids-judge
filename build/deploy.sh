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
