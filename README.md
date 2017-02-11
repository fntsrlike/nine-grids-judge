##### 目錄

```
一、安裝
    1.1 環境需求
        1.1.1 安裝 Ruby
        1.1.2 安裝 MySQL
    1.2 初始化
    1.3 部署
二、程式架構
    2.1 檔案結構
    2.2 相依套件
    2.3 設計
三、Rake 工具
    3.1 dev
        3.1.1 dev:build
        3.1.2 dev:reset
    3.2 user
        3.2.1 user:basic
        3.2.2 user:import
        3.2.3 user:passwd
        3.2.4 user:passwd_student
    3.3 exam
        3.3.1 exam:fake
四、說明
    4.1 使用者身份
        4.1.1 系統管理員（admin）
        4.1.2 管理員 / 審題者 / 助教（manager）
        4.1.1 學生（student）
    4.2 編輯器語法
    4.3 審題排序演算法
```

## 前置知識
- [二十分鐘 Ruby 體驗](http://www.ruby-lang.org/zh_tw/documentation/quickstart/)
- [Ruby 使用手冊](http://guides.ruby.tw/ruby/)
- [Rails 初上手指南 (Rails 3.0)](http://guides.ruby.tw/rails3/getting_started.html)
- [Ruby 風格指南](https://github.com/JuanitoFatas/ruby-style-guide/blob/master/README-zhTW.md)
- [Ruby on Rails 實戰聖經](https://ihower.tw/rails4/)

## 安裝

### 1.1 環境需求
- Ubuntu 14.04 (Linux kernel 3.13.0-68-generic)
- Ruby 和 Ruby on Rails 相關環境，本程式開發時，是採用 Ruby 2.3.1 和 Rails 4.2.3。
- MySQL Ver 14.14 Distribute 5.5.46
- CMake

#### 1.1.1 Ruby 安裝
##### 自行編譯

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

##### 透過 RVM 安裝
請參照 [RVM 官網](https://rvm.io) 的說明。

##### 透過本專案提供的安裝腳本安裝
./deploy.sh

#### 1.1.2 MySQL 安裝
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

### 1.2 初始化

#### 1.2.1 環境變數設定
- 本程式是使用 Ruby on Rails 4.2 框架寫成，所有設定皆與框架文件相同。本文件僅提供基本安裝方式，若有其他技術問題，可去查詢框架相關文件，就不再一一贅述。
- 本程式已經將需要動到的設定都放置在專案根目錄的 `.env` 檔案中，請根據您目前的環境去設定即可

#### 1.2.2 Rails 初始化
1. 在命令列輸入 `./bin/bundle` 去安裝 Gems
1. 在命令列輸入 `./bin/rake db:migrate` 去部署資料庫
1. 在命令列輸入 `./bin/rails s` 去啟動程式

即可透過 port 3000 訪問程式

### 1.3 部署

若希望以較正式的方式營運本程式，推薦使用 Nginx + Passenger 做代理伺服器。可以參照 [Ruby on Rails 實戰聖經 - 網站佈署](https://ihower.tw/rails4/deployment.html) 的 **Nginx + Passenger** 章節。

## 二、程式架構

使用 Ruby on Rails 作為框架，該框架採用 MVC 架構，並搭配 Gem 作為套件管理系統。以下為該框架的基本架構。

```
app/         : 主要程式邏輯所在
db/          : 資料庫 Schema 與 data
public/      : 公開資料放置處
Gemfile      : 相依套件
Gemfile.lock : 目前相依套件使用的版本號
.env         : 基礎設定

app/assets/      : 前端程式碼（JavaScript、CSS）放置處
app/controllers/ : 控制器放置處，系統主要邏輯
app/mailers/     : 寄信功能相關邏輯
app/models/      : 資料庫模型
app/views/       : 使用者介面，
```

## 三、Rake 工具

本系統透過編寫 Rake 去進行部分工作的自動化。使用方式為 `rake [namespace]:[task_name]`，本系統共有 dev, users, exam 三個 namespace 作為工作的分類。

預設指令都會以開發環境 (Development) 為主，若是要套用在正式環境 (Production)，在指令前面需要加上 `RAILS_ENV=production` 作為環境設定。例如；

```bash
$ RAILS_ENV=production rake dev:build
```

### 3.1 dev
關於系統相關的指令，因為偏向開發者在使用，故以 dev 作為 namespace。

#### 3.1.1 dev:build

```
$ rake dev:build
```

本指令用來建立/重建系統，現存資料會全部清空，不可還原，使用時務必小心。會依序做以下事情：

1. 清空 tmp/ 目錄下的 Session、快取以及 Socket 檔案。
1. 刪掉 log/ 目錄下所有的 *.log 檔案
1. 刪除現在使用的資料庫
1. 建立一個新的資料庫
1. 對新的資料庫做 schema 的 migrate

#### 3.1.1 dev:reset

```
$ rake dev:reset
```

本指令是用來重啟系統，通常在開發者更新系統程式後，會使用本指令。本指令會依序做以下事情：

1. 清空 Rails 的快取（不包括 Sesssion、Socket）
1. 重新編譯 assets
1. 要求網頁伺服器重啟本系統

### 3.2 users
和使用者相關的指令。

#### 3.2.1 user:basic

```
$ rake user:basic
```

本指令會建立最基本的三個使用者，每個使用者對應到一個身份。使用者帳號分別為 `admin`, `manager`, `student`，密碼都是 `qwer1234`。

#### 3.2.2 user:import

```bash
$ rake user:import\[檔案名稱\]

# eg
$ rake user:import\[list.csv\]
```

本指令會匯入一個不含欄位、並以逗號作為分隔字元的 csv 檔案，欄位順序如下：

```
真實名稱,帳號,密碼,電子郵件,電話號碼,身份
```

分隔符號請只使用 `,`，不要包含空白。密碼建議留空，再利用 `user:passwd`、`user:passwd_student` 去設定亂數密碼，並由系統寄信通知使用者。身份只能使用 `admin`, `manager`, `student` 三種，若不是以上三種，則自動判定為 `student`。建議可以使用試算表軟體編輯，再匯出為 csv 檔案。

一個正確的內容大致如下：

```
林若虛,ruoshi,,fntsrlike@g.ncu.edu.tw,0923456789,admin
查爾德,chorld,,chorld@oolab.ncu.tw,0934567890,manager
馬鈴薯,potato,,potato@oolab.ncu.tw,0945678901,manager
葉麥克,micheal,,phd@oolab.ncu.tw,0967890123,manager
趙一號,103525001,,103525001@cc.ncu.edu.tw,0900123451,student
錢二號,103525002,,103525002@cc.ncu.edu.tw,0900123452,student
孫三號,103525003,,103525003@cc.ncu.edu.tw,0900123453,student
```

#### 3.2.3 user:passwd

```bash
$ rake user:passwd\[帳號\]

# eg
$ rake user:passwd\[ruoshi\]
```

本指令是用來將指定的使用者重設密碼，並將新密碼寄信給使用者。

#### 3.2.4 user:passwd_student

```
$ rake user:passwd_student
```

本指令是用來重設所有身份為學生的使用者的密碼，並將新密碼寄信給使用者。

### 3.2 exam
與題庫相關的工具。

#### 3.2.2 exam:fake

```
$ rake exam:fake
```

本指令是用來產生假資料，會產生 12 個章節，每章節有 15 個題目，方便開發者做測試。

## 四、說明

### 4.1 使用者身份

#### 4.1.1 系統管理員（admin）
為系統最高權限管理者，擁有 manger 的所有權限，並且能夠新增、編輯使用者資料。

#### 4.1.2 管理員 / 審題者 / 助教（manager）
本系統的主要管理者，擁有章節、題目的建立、修改與刪除權限，並能夠審核學生送交的答案，給予回饋和審核結果。

#### 4.1.1 學生（student）
本系統的主要使用者，只看得到已啟用的章節、該章節的題目以及自己回答過題目的內容、狀態和助教審題給的的回饋。

每個學生在每個章節會有一個專屬的九宮格，九宮格的每個格子對應到該章節的一個題目，對應關係會在該學生第一次打開章節時亂數產生，所以每個學生所擁有的九宮格題目對應是不一樣的。

### 4.2 編輯器語法
本系統在文字框（textarea）的編輯，都是有支援 Markdown 語法的，使用的是 Github Flavor 的渲染。詳細可以看文字框下方所附的超連結。

### 4.3 審題排序演算法
為了使每位學生得到助教審題資源的公平化，以及避免學生爛答，本系統在針對助教所看到的改題列表，會依下列判斷做為排序。

1. 學生是否有通過該題所屬章節，尚未通過者會有較高的排序權重
1. 學生今天被審核過次數，越低者會有較高的排序權重
1. 該題提交的時間，越早的會有較高的排序權重

以上面演算法所做的排序，大致會呈現下面的結果

1. 未通過該章節，被審數低，提交時間較**早**
1. 未通過該章節，被審數低，提交時間較**晚**
1. 未通過該章節，被審數**高**，提交時間較早
1. 未通過該章節，被審數**高**，提交時間較晚
1. **已**通過該章節，被審數低，提交時間較早
1. **已**通過該章節，被審數低，提交時間較晚
1. 已通過該章節，被審數高，提交時間較早
1. 已通過該章節，被審數高，提交時間較晚