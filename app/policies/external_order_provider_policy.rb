class ExternalOrderProviderPolicy < ApplicationPolicy

  def index?
    show?
  end

  def show?
    user.has_permission?(:read_external_order_provider)
  end

  def new?
    user.has_permission?(:create_external_order_provider)
  end

  def create?
    new?
  end

  def edit?(resource)
    if (resource.solicitud_enviada? || resource.proveedor_auditoria?) && resource.provider_sector == user.active_sector
      user.has_permission?(:update_external_order_provider)
    end
  end

  def edit_applicant_on_solicitud?(resource)
    if resource.provision? && resource.proveedor_auditoria? && resource.provider_sector == user.active_sector
      user.has_permission?(:update_external_order_provider)
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def destroy?(resource)
    if resource.provision? && resource.proveedor_auditoria? && resource.provider_sector == user.active_sector
      user.has_permission?(:destroy_external_order_provider)
    end
  end

  def edit_products?(resource)
    if %w[solicitud_enviada proveedor_auditoria].any?(resource.status) && resource.provider_sector == user.active_sector
      user.has_permission?(:update_external_order_provider) || create?
    end
  end

  def can_send?(resource)
    if resource.proveedor_aceptado? && resource.provider_sector == user.active_sector
      user.has_permission?(:send_external_order_provider)
    end
  end

  def rollback_order?(resource)
    if resource.provider_sector == user.active_sector && resource.proveedor_aceptado?
      user.has_permission?(:return_external_order_provider)
    end
  end

  def accept_order?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.active_sector
      user.has_permission?(:accept_external_order_provider)
    end
  end

  def nullify_order?(resource)
    if (['solicitud_enviada'].include? resource.status) && resource.provider_sector == user.active_sector
      user.has_permission?(:nullify_external_order_provider)
    end
  end
end