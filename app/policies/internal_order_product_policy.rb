class InternalOrderProductPolicy < ApplicationPolicy
  def edit_request_quantity?
    if record.is_provision? && record.get_order.proveedor_auditoria?
      user.has_permission?(:update_internal_order_provider)
    elsif record.is_solicitud? && record.get_order.solicitud_auditoria?
      user.has_permission?(:update_internal_order_applicant)
    end
  end

  def edit_product?
    if record.added_by_sector_id == user.sector_id && record.is_proveedor_auditoria?
      user.has_permission?(:update_internal_order_provider)
    elsif record.added_by_sector_id == user.sector_id && record.is_solicitud_auditoria?
      user.has_permission?(:update_internal_order_applicant)
    end
  end

  def add_product?
    if record.new_record?
      if record.is_proveedor_auditoria?
        user.has_permission?(:update_internal_order_provider)
      elsif record.is_solicitud_auditoria?
        user.has_permission?(:update_internal_order_applicant)
      end
    end
  end

  def destroy?
    if record.added_by_sector_id.present? && record.added_by_sector == user.sector
      user.has_permission?(:update_internal_order_applicant) || user.has_permission?(:update_internal_order_provider)
    end
  end
end
