class StockMovementPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_stocks)
  end
end
