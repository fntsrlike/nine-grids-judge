class UpdateCharacterToUtf8mb4 < ActiveRecord::Migration
  @utf8_text_pairs = {
    answers:    ['content'],
    chapters:   ['description'],
    judgements: ['content'],
    quizzes:    ['content', 'reference']
    # ...
  }

  def self.up
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8mb4;"

      ActiveRecord::Base.connection.tables.each do |table|
        execute "ALTER TABLE `#{table}` CHARACTER SET = utf8mb4;"
      end

      @utf8_text_pairs.each do |table, cols|
        cols.each do |col|
          execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8mb4  NULL;"
        end
      end
    end
  end

  def self.down
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      execute "ALTER DATABASE `#{ActiveRecord::Base.connection.current_database}` CHARACTER SET utf8;"

      ActiveRecord::Base.connection.tables.each do |table|
        execute "ALTER TABLE `#{table}` CHARACTER SET = utf8;"
      end

      @utf8_text_pairs.each do |table, cols|
        cols.each do |col|
          execute "ALTER TABLE `#{table}` CHANGE `#{col}` `#{col}` TEXT  CHARACTER SET utf8  NULL;"
        end
      end
    end
  end
end
