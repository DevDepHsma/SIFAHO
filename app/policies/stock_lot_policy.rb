class StockLotPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_lot_stocks)
  end
end
