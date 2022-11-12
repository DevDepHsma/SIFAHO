class DropRoleColumnFromPermissionRequest < ActiveRecord::Migration[5.2]
  def up
    remove_column :permission_requests, :role, :string
    add_reference :permission_requests, :aproved_by, index: true
  end

  def down
    add_column :permission_requests, :role, :string
    remove_reference :permission_requests, :aproved_by, index: true
  end
end
