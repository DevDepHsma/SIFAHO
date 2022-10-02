class InpatientPrescriptionPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    # user.has_any_role?(:admin)
    false
  end

  def new?
    user.has_any_role?(:admin, :medico, :recetar_internacion)
  end

  def set_products?
    if Date.today <= record.date_prescribed
      user.has_any_role?(:admin, :medico, :recetar_internacion)
    end
  end

  def create?
    new?
  end

  def edit?
    if !record.parent_order_products.any?(&:provista?) && set_products?
      user.has_any_role?(:admin, :medico)
    end
  end

  def update?
    edit?
  end

  def delivery?
    if Date.today <= record.date_prescribed && (record.pending? || record.parcialmente_dispensada?) && record.parent_order_products.any?(&:sin_proveer?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
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
      user.has_any_role?(:admin, :medico, :recetar_internacion)
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
