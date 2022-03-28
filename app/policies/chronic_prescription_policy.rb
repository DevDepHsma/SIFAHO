class ChronicPrescriptionPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_chronic_prescriptions)
  end

  def new?
    user.has_permission?(:create_chronic_prescriptions)
  end

  def create?
    new?
  end

  def edit?
    if (record.pendiente? || record.dispensada_parcial?) && (DateTime.now.to_time < record.expiry_date)
      user.has_permission?(:update_chronic_prescriptions)
    end
  end

  def edit_dispense?
    if record.dispensada_parcial?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end

  def update?
    edit?
  end

  def dispense_new?
    if record.any_product_without_dispensing? && !record.vencida? && !record.dispensada?
      user.has_permission?(:dispense_chronic_prescriptions)
    end
  end

  def dispense?
    dispense_new?
  end

  def return_dispensation?
    # no se puede retornar ninguna dispensacion, si la receta esta vencida
    !record.vencida?
  end

  def destroy?
    if record.pendiente?
      user.has_any_role?(:admin, :farmaceutico)
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

  def finish?
    unless record.any_product_without_dispensing? || record.dispensada? || record.vencida?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic)
    end
  end
end
