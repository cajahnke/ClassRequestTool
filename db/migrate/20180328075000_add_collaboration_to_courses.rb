class AddCollaborationToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :collaboration, :boolean
  end
end
