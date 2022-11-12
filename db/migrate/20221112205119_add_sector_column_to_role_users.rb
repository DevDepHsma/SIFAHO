class AddSectorColumnToRoleUsers < ActiveRecord::Migration[5.2]
  def up
    add_reference :user_roles, :sector, index: true
  end
  
  def down
    remove_reference :user_roles, :sector, index: true
  end
end
