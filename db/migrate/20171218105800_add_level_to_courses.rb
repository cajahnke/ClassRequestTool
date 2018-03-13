class AddLevelToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :level, :input, :limit => 100
  end
end
