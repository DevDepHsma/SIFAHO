class NotificationPolicy < ApplicationPolicy
  def index?
    user.roles.any? && false
  end
end
