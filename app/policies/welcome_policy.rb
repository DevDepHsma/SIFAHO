class WelcomePolicy < ApplicationPolicy
  def index?
    user.active? && user.active_sector.present?
  end
end
