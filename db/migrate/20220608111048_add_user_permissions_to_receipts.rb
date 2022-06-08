class AddUserPermissionsToReceipts < ActiveRecord::Migration[5.2]
  def up
    @users = User.joins(:roles).where('roles.name': ['farmaceutico'])
    @permissions = Permission.where(name: ['create_receipts read_receipts update_receipts destroy_receipts receive_receipts'])
    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.create(user: user, sector: sector, permission: permission)
        end
      end
    end
  end

  def down
    @users = User.joins(:roles).where('roles.name': ['farmaceutico'])
    @permissions = Permission.where(name: ['create_receipts read_receipts update_receipts destroy_receipts receive_receipts'])
    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.find_by(permission_id: permission.id).destroy
        end
      end
    end
  end
end
