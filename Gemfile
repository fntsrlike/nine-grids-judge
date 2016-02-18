# 中央大學網路開源社鏡像
source 'https://rubygems.nos.ncu.edu.tw'

# Official (on Amazon S3)
# source 'https://rubygems.org'

# 指定 Ruby 版本
ruby "2.2.2"


# 指定 RubyGems 的版本
#
# 1. 不指定版本: 盡可能使用最新版。
#    eg. `gem "nokogiri"`
#
# 2. 明確指定版本。
#    eg. `gem "rails", "4.1.1"`
#
# 3. 介於當前次版本號到主版本號進位的版本
#    eg. `gem "rack", "~> 1.5"` 會使用介於 1.5 ~ 2.0 的最新版（不包含 2.0）。
#    eg. `gem "kaminari", "~> 0.15.1"` 會使用介於 0.15.1 ~ 0.16.0 的最新版（不包含 0.16.0）
#    eg. `gem "sinatra", "~> 1"` 會使用介於 1.0 ~ 2.0 的最新版（不包含 2.0）
#
# 4. 大於等於
#    eg. `gem "uglifier", ">= 1.3"` 會使用 1.3 以上（包含 1.3）的最新版本。
#


#
# Core Gem
#

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.4'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 2.7.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', '>= 0.12.2', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.1.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '>= 2.5.3'

# Fix conflict between jquery and turbolinks
gem 'jquery-turbolinks', '~> 2.1.0'

# Use rails_autolink for autolink before the issue of redcarpet fixed
gem 'rails_autolink', '~> 1.1'

# Sematic UI
gem 'semantic-ui-sass', '~> 2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.4'

# Load environment variable from .env file
gem 'dotenv-rails', '~> 2.1', :group => "production"


#
# DB Adapater
#

# Don't need install SQL Client/Server
gem 'sqlite3', '~> 1.3'

# Need to at least intsall MySQL Client
#
# Debian: `sudo apt-get install libmysqlclient-dev mysql-client`
# OS X: `brew install postgresql`
#
gem "mysql2", '~> 0.4', :group => "production"

# Need to at least intsall PostgreSQL Client
#
# Debian: `sudo apt-get install postgresql-client-9.4 libpq-dev
# OS X: `brew install postgresql`
#
gem "pg", '~> 0.18', :group => "production"



#
# Member and Permission manage system
#

# Authorization
gem 'devise', '~> 3.5'

# Roles define
gem 'rolify', '~> 5.0'

# Permission and Abillity
gem 'cancancan', '~> 1.13'


#
# Markdown render and Syntax highlighter
#

# Use HTML pipeline for rendering
gem 'html-pipeline', '~> 2.3.0'

# Markdown render
gem 'github-markdown'

# Code highlighter
# gem 'pygments.rb', '~> 0.6.3'

# Use GitHub Linguist for language detection
gem 'github-linguist'


# Others
#

# Pagination
gem 'kaminari'

# Filter
gem 'has_scope'

# Fake Mail Server
gem "letter_opener", :groups => [:development, :test]
