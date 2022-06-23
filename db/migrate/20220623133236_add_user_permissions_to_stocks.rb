class AddUserPermissionsToStocks < ActiveRecord::Migration[5.2]
  def up
    @users = User.joins(:roles).where('roles.name': ['admin farmaceutico auxiliar_farmacia'])
    @permissions = Permission.where(name: ['read_stocks read_lot_stocks read_archive_stocks create_archive_stocks return_archive_stocks read_movement_stocks'])
    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.create(user: user, sector: sector, permission: permission)
        end
      end
    end
  end

  def down
    @users = User.joins(:roles).where('roles.name': ['admin farmaceutico auxiliar_farmacia'])
    @permissions = Permission.where(name: ['read_stocks read_lot_stocks read_archive_stocks create_archive_stocks return_archive_stocks read_movement_stocks'])
    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.find_by(permission_id: permission.id).destroy
        end
      end
    end
  end
end
