class LotArchivePolicy < ApplicationPolicy
  def index?
    show?
  end
  
  def show?
    user.has_permission?(:read_archive_stocks)
  end

  def new?(lot_stock)
    user.has_permission?(:create_archive_stocks) && lot_stock.quantity > 0
  end

  def create?
    new?(record.lot_stock)
  end

  def return_archive?
    unless record.retornado?
      diff_in_hours = (DateTime.now.to_time - record.created_at.to_time) / 1.hours
      if diff_in_hours < 48
        user.has_permission?(:return_archive_stocks)
      end
    end
  end

  def return_archive_modal?
    return_archive?
  end
end
