class CreatePermissionRequestRoles < ActiveRecord::Migration[5.2]
  def up
    create_table :permission_request_roles do |t|
      t.references :role, foreign_key: true
      t.references :permission_request, foreign_key: true
      t.timestamps
    end
  end

  def down
    drop_table :permission_request_roles
  end
end
