class AddUserPermissionsToOrders < ActiveRecord::Migration[5.2]
  def up
    @users = User.joins(:roles).where('roles.name': ['farmaceutico','auxiliar_farmacia', 'enfermero', 'medico'])
    @permissions = Permission.where(name: ['read_internal_order_applicant',
                                            'create_internal_order_applicant',
                                            'update_internal_order_applicant',
                                            'send_internal_order_applicant',
                                            'receive_internal_order_applicant',
                                            'return_internal_order_applicant',
                                            'read_internal_order_provider',
                                            'create_internal_order_provider',
                                            'update_internal_order_provider',
                                            'send_internal_order_provider',
                                            'nullify_internal_order_provider',
                                            'return_internal_order_provider',
                                            'read_external_order_applicant',
                                            'create_external_order_applicant',
                                            'update_external_order_applicant',
                                            'send_external_order_applicant',
                                            'receive_external_order_applicant',
                                            'return_external_order_applicant',
                                            'read_external_order_provider',
                                            'create_external_order_provider',
                                            'update_external_order_provider',
                                            'send_external_order_provider',
                                            'nullify_external_order_provider',
                                            'return_external_order_provider',
                                            'accept_external_order_provider'
                                          ])

    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.create(user: user, sector: sector, permission: permission)
        end
      end
    end
  end

  def down
    @users = User.joins(:roles).where('roles.name': ['farmaceutico','auxiliar_farmacia', 'enfermero', 'medico'])
    @permissions = Permission.where(name: ['read_internal_order_applicant',
                                            'create_internal_order_applicant',
                                            'update_internal_order_applicant',
                                            'send_internal_order_applicant',
                                            'receive_internal_order_applicant',
                                            'return_internal_order_applicant',
                                            'read_internal_order_provider',
                                            'create_internal_order_provider',
                                            'update_internal_order_provider',
                                            'send_internal_order_provider',
                                            'nullify_internal_order_provider',
                                            'return_internal_order_provider',
                                            'read_external_order_applicant',
                                            'create_external_order_applicant',
                                            'update_external_order_applicant',
                                            'send_external_order_applicant',
                                            'receive_external_order_applicant',
                                            'return_external_order_applicant',
                                            'read_external_order_provider',
                                            'create_external_order_provider',
                                            'update_external_order_provider',
                                            'send_external_order_provider',
                                            'nullify_external_order_provider',
                                            'return_external_order_provider',
                                            'accept_external_order_provider'
                                          ])

    @users.each do |user|
      user.sectors.each do |sector|
        @permissions.each do |permission|
          PermissionUser.find_by(permission_id: permission.id).destroy
        end
      end
    end
  end
end
