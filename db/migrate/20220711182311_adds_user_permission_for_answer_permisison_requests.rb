class AddsUserPermissionForAnswerPermisisonRequests < ActiveRecord::Migration[5.2]
  def up
    # User permissions
    permission_module = PermissionModule.find_by(name: 'Usuario')
    Permission.create(name: 'answer_permission_request', permission_module: permission_module)
  end

  def down
    permission = Permission.find_by(name: 'answer_permission_request')
    permission.destroy
  end
end
