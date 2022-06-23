class LotStockPolicy < ApplicationPolicy
  def index?
    show?
  end

  def lot_stocks_by_stock?
    show?
  end

  def show?
    user.has_permission?(:read_lot_stocks)
  end
end
