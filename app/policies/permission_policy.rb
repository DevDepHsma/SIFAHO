class PermissionPolicy < ApplicationPolicy
  def edit?(target_user)
    (user.has_permission?(:update_permissions) && target_user.active?) ||
    (user.has_permission?(:answer_permission_request) && target_user.permission_req?)
  end

  def update?(target_user)
    edit?(target_user)
  end
end
