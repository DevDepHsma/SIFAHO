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
    if user.has_any_role?(:admin, :farmaceutico) && record.auditoria?
      return record.applicant_sector == user.sector
    end
  end

  def delete?
    destroy?
  end

  def rollback_order?
    user.has_any_role?(:admin) && record.receipt_products.any?(&:has_available_lot_quantity?) && record.recibido?
  end

  def receive?
    user.has_permission?(:receive_receipts)
  end
end
