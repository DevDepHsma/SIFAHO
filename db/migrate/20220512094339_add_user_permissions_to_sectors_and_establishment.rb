class AddUserPermissionsToSectorsAndEstablishment < ActiveRecord::Migration[5.2]
  def up
    @users = User.joins(:roles).where('roles.name': ['farmaceutico', 'auxiliar_farmacia', 'farmaceutico_central'])
    @permissions = Permission.where(name: ['read_establishments', 'read_sectors'])
    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.create(user: user, sector: sector, permission: permission)
        end
      end
    end
  end

  def down
    @users = User.joins(:roles).where('roles.name': ['farmaceutico', 'auxiliar_farmacia', 'farmaceutico_central'])
    @permissions = Permission.where(name: ['read_establishments', 'read_sectors'])
    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.find_by(permission_id: permission.id).destroy
        end
      end
    end
  end
end
