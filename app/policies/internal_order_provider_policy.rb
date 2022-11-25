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

  def create?
    new?
  end

  def edit?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.active_sector
      user.has_permission?(:update_internal_order_provider)
    end
  end

  def edit_products?(resource)
    if %w[solicitud_enviada proveedor_auditoria].any?(resource.status) && resource.provider_sector == user.active_sector
      user.has_permission?(:update_internal_order_provider) || create?
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def can_send?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.active_sector
      user.has_permission?(:send_internal_order_provider)
    end
  end

  def destroy?(resource)
    if (resource.provision? && resource.proveedor_auditoria?) && resource.provider_sector == user.active_sector
      user.has_permission?(:destroy_internal_order_provider)
    end
  end

  def rollback_order?(resource)
    if resource.provider_sector == user.active_sector && resource.provision_en_camino?
      user.has_permission?(:return_internal_order_provider)
    end
  end

  def nullify_order?(resource)
    if resource.provider_sector == user.active_sector && resource.solicitud? && (resource.solicitud_enviada? || resource.proveedor_auditoria?)
      user.has_permission?(:nullify_internal_order_provider)
    end
  end
end
