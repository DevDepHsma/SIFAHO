class InternalOrderProviderPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_internal_order_provider)
  end

  def new?
    user.has_permission?(:create_internal_order_provider)
  end

  def new_report?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def create?
    new?
  end

  def edit?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.sector
      user.has_permission?(:update_internal_order_provider)
    end
  end

  def edit_products?(resource)
    if %w[solicitud_enviada proveedor_auditoria].any?(resource.status) && resource.provider_sector == user.sector
      user.has_permission?(:update_internal_order_provider) || create?
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def can_send?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.sector
      user.has_permission?(:send_internal_order_provider)
    end
  end

  def destroy?(resource)
    if (resource.provision? && resource.proveedor_auditoria?) && resource.provider_sector == user.sector
      user.has_permission?(:destroy_internal_order_provider)
    end
  end

  def generate_report?
    new_report?
  end

  def rollback_order?(resource)
    if resource.provider_sector == user.sector && resource.provision_en_camino?
      user.has_permission?(:return_internal_order_provider)
    end
  end

  def nullify_order?(resource)
    if resource.provider_sector == user.sector && resource.solicitud? && (resource.solicitud_enviada? || resource.proveedor_auditoria?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
end
