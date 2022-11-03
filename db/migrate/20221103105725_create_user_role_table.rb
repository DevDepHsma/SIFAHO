class CreateUserRoleTable < ActiveRecord::Migration[5.2]
  def up
    create_table :user_roles do |t|
      t.references :user, index: true, foreign_key: { to_table: :users }
      t.references :role, index: true, foreign_key: { to_table: :roles }
    end
  end

  def down
    drop_table :user_roles, if_exists: true
  end
end
