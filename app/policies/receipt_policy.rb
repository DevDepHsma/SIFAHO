class ReceiptPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :farmaceutico)
  end

  def new?
    create?
  end

  def update?
    edit?
  end

  def edit?
    if record.auditoria? && record.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico)
    end
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
    user.has_any_role?(:admin, :farmaceutico)
  end
end
