# 這個檔案是為了解決 MySQL 所以長度限制導致 migrate 出錯的問題
# 這個問題來自於 Rails 的 varchar 類型欄位預設長度是 255
# 而 MySQL 用來當作索引的鍵值長度不能超過 767 bytes
# 在一般 utf8 編碼的情況下是沒問題的，每個字元的大小最大就 3 bytes，最大就 765 bytes
# 但為了避免使用者輸入表情符號字元，像是 🛏，導致程式無法讀取而當掉
# 本系統將編碼改成 utf8mb4，而每個字元固定為 4 byte️，所以大小就會有 1020byte 而超過支援
# 為了改善這個問題，我們在這裡將 varchar 的長度改成 191，大小就會變成 764，符合 MySQL 標準
# 因而解決這個問題。
#
# 詳細資訊可以閱讀這篇議題：
# https://github.com/rails/rails/issues/9855

require 'active_record/connection_adapters/abstract_mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter
      NATIVE_DATABASE_TYPES[:string] = { :name => "varchar", :limit => 191 }
    end
  end
end