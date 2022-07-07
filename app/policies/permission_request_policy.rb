class PermissionRequestPolicy < ApplicationPolicy

  def index?
    user.has_any_role?(:admin, :gestor_usuarios)
  end

  def create?
    user.permissions.none? && user.permission_requests.none?
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:admin)
  end

  def request_in_progress?
    user.permission_requests.any?(&:in_progress?)
  end

  def end?
    if record.nueva?
      update?
    end
  end

  private

  def index_user
    [ :admin, :gestor_usuarios ]
  end

  def update
    [ :admin, :gestor_usuarios ]
  end

  def update_permissions
    [ :admin, :gestor_usuarios ]
  end
end
