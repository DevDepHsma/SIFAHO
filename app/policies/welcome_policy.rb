class WelcomePolicy < ApplicationPolicy
  def index?
    user.active?
  end
end
