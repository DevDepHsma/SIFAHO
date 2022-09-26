class DashboardPolicy < ApplicationPolicy
  def sidebar?
    user.permissions.any?
  end
end
