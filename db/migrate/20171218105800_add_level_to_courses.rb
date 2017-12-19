class AddLevelToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :level, :text
  end
end
