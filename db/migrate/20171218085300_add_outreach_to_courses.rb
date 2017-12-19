class AddOutreachToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :outreach, :boolean
  end
end
