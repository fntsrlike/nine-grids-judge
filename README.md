## Install

### Requirement

- Ubuntu 14.04 (Linux kernel 3.13.0-68-generic)
- Ruby 和 Ruby on Rails 相關環境，本程式開發時，是採用 Ruby 2.2.2 和 Rails 4.2.3。
- MySQL Ver 14.14 Distrib 5.5.46

### Ruby 安裝
#### 自行編譯
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo dpkg-reconfigure tzdata

sudo apt-get install -y build-essential git-core bison openssl libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3  autoconf libc6-dev libpcre3-dev curl libcurl4-nss-dev libxml2-dev libxslt-dev imagemagick nodejs libffi-dev

wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
tar xvfz ruby-2.2.2.tar.gz
cd ruby-2.2.2
./configure
make
sudo make install
```

#### 透過 RVM 安裝
請參照 [RVM 官網](https://rvm.io) 的說明。

### MySQL 安裝
```bash
sudo apt-get install mysql-common mysql-client libmysqlclient-dev mysql-server
sudo gem install mysql2 --no-ri --no-rdoc
mysql -u root -p
CREATE DATABASE your_production_db_name CHARACTER SET utf8;
```

如果你的資料庫沒有要安裝在本機內，請安裝 Client 的 Library 即可
```
sudo apt-get install libmysqlclient-dev
```

### Setting

- 本程式是使用 Ruby on Rails 4.2.3 框架寫成，所有設定皆與框架文件相同。本文件僅提供基本安裝方式，若有其他技術問題，可去查詢框架相關文件，就不再一一贅述。
- 本程式已經將需要動到的設定都放置在專案根目錄的 `.env` 檔案中，請根據您目前的環境去設定即可

### Setup

1. 在命令列輸入 `./bin/bundle` 去安裝 Gems
2. 在命令列輸入 `./bin/rake db:migrate` 去部署資料庫
3. 在命令列輸入 `./bin/rails s` 去啟動程式

即可透過 port 3000 訪問程式

### Deploy

若希望以較正式的方式營運本程式，推薦使用 Nginx + Passenger 做代理伺服器。可以參照 [Ruby on Rails 實戰聖經 - 網站佈署](https://ihower.tw/rails4/deployment.html) 的 **Nginx + Passenger** 章節。

## Program FS Structure

```
app/    : 主要程式邏輯所在
db/     : 資料庫 Schema 與 data
public/ : 公開資料放置處
.env    : 基礎設定
.Gemfile: 相依套件

app/assets/     : 前端程式碼（JavaScript、CSS）放置處
app/controllers/: 控制器放置處，系統主要邏輯
app/mailers/    : 寄信功能相關邏輯
app/models/     : 資料庫模型
app/views/      : 使用者介面，
```