class WelcomePolicy < ApplicationPolicy
  def index?
    user.active? && user.sector.present?
  end
end
