class AddSemesterLongToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :semester_long, :boolean
  end
end
