class DropUsersRolesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :users_roles, if_exists: true
  end
end
