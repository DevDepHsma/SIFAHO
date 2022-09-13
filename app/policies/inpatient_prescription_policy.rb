class InpatientPrescriptionPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    false
  end

  def new?
    false
  end

  def set_products?
    if Date.today <= record.date_prescribed
      false
    end
  end

  def create?
    new?
  end

  def edit?
    if !record.parent_order_products.any?(&:provista?) && set_products?
      false
    end
  end

  def update?
    edit?
  end

  def delivery?
    if Date.today <= record.date_prescribed && (record.pending? || record.parcialmente_dispensada?) && record.parent_order_products.any?(&:sin_proveer?)
      false
    end
  end

  def update_with_delivery?
    delivery?
  end

  def return_dispensation?
    # no se puede retornar ninguna dispensacion, si la receta esta vencida
    !record.vencida?
  end

  def destroy?
    if !record.parent_order_products.any?(&:provista?)
      false
    end
  end

  def delete?
    destroy?
  end

  def nullify?
    if record.provider_sector == user.sector && record.solicitud? && (record.solicitud_enviada? || record.proveedor_auditoria?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
end
