class ChangeSemesterLongToSchedulingInCourses < ActiveRecord::Migration
  def change
    rename_column :courses, :semester_long, :scheduling
  end
end
