class AddCloneToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :clone, :string, :limit => 100
  end
end
