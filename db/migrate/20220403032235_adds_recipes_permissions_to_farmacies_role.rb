class AddsRecipesPermissionsToFarmaciesRole < ActiveRecord::Migration[5.2]
  def up
    @enable_recipes_permissions = Role.eager_load(:users).where(name: ['farmaceutico','auxiliar_farmacia'])

    @permissions_module = PermissionModule.eager_load(:permissions).where(name: ['Recetas Crónicas', 'Recetas Ambulatorias'])
    @professional_permissions = Permission.includes(:permission_module).where('permission_modules.name': 'Profesionales').where.not(name: ['destroy_professionals', 'update_professionals'])

    @enable_recipes_permissions.each do |role|
      role.users.each do |user|
        user.sectors.each do |sector|
          @permissions_module.each do |pm|
            pm.permissions.each do |permission|
              PermissionUser.create(user: user, sector: sector, permission: permission)
            end
          end
          
          @professional_permissions.each do |permission|
            PermissionUser.create(user: user, sector: sector, permission: permission)
          end
        end
      end
    end

  end

  def down
    @enable_recipes_permissions = Role.eager_load(:users).where(name: ['farmaceutico','auxiliar_farmacia'])

    @enable_recipes_permissions.each do |role|
      role.users.each do |user|
        user.permission_users.each do |permission|
          permission.destroy
        end
      end
    end
  end
end
