class ReceiptPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_receipts)
  end

  def create?
    user.has_permission?(:create_receipts)
  end

  def new?
    create?
  end

  def update?
    if record.auditoria? && record.applicant_sector == user.sector
      user.has_permission?(:update_receipts)
    end
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:rollback_receipts) && record.auditoria?
  end

  def rollback_order?
   user.has_permission?(:rollback_receipts) && record.receipt_products.all?(&:has_available_lot_quantity?) && record.recibido?
  end

  def receive_order?
    user.has_permission?(:receive_receipts) && record.auditoria?
  end
end
