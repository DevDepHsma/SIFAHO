class DropResourcesColumnFromRoles < ActiveRecord::Migration[5.2]
  def up
    remove_column :roles, :resource_type, :string
    remove_column :roles, :resource_id, :integer
  end

  def down
    add_column :roles, :resource_type, :string
    add_column :roles, :resource_id, :integer
  end
end
