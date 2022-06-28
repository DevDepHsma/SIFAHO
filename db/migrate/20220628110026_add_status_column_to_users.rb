class AddStatusColumnToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :status, :integer, default: 0
    # Current users
    User.where.not(sector_id: nil).each(&:active!)
  end

  def down
    remove_column :users, :status
  end
end
