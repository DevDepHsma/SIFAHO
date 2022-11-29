class AddsStatusColumnToUserSectors < ActiveRecord::Migration[5.2]
  def up
    add_column :user_sectors, :status, :integer, default: 0
  end

  def down
    remove_column :user_sectors, :status, :integer
  end
end
