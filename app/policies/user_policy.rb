class UserPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_users)
  end

  def show?
    user.has_permission?(:read_users)
  end

  def update?
    record == user
  end

  def change_sector?
    record.sectors.count > 1
  end

  def edit_permissions?
    user.has_permission?(:update_permissions)
  end
end