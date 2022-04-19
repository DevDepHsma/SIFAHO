class ExternalOrderProductPolicy < ApplicationPolicy
  def edit_request_quantity?
    if record.is_provision? && record.get_order.proveedor_auditoria?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    elsif record.is_solicitud? && record.get_order.solicitud_auditoria?
      user.has_permission?(:update_external_order_applicant)
    end
  end

  def edit_product?
    edit_request_quantity?
  end

  def remove_association?
    if record.is_provision? || record.new_record?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    elsif !record.is_provision? && record.get_order.solicitud_auditoria?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end

  def destroy?
    if record.added_by_sector_id.present? && record.added_by_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    # elsif !record.is_provision? && record.get_order.solicitud_auditoria?
    #   user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end
end
