class AddNotesToSections < ActiveRecord::Migration
  def change
    add_column :sections, :notesrm , :text
  end
end
