class StockPolicy < ApplicationPolicy
  def sidebar_menu?
    user.has_permission?(:read_receipts) || index?
  end

  def index?
    show?
  end

  def show?
    user.has_permission?(:read_stocks)
  end

  def movements?
    user.has_permission?(:read_movement_stocks)
  end
end
