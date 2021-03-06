class ExternalOrderApplicantPolicy < ApplicationPolicy

  def index?
    show?
  end

  def show?
    user.has_permission?(:read_external_order_applicant)
  end

  # new version
  def new?
    user.has_permission?(:create_external_order_applicant)
  end

  def create?
    new?
  end

  def edit?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:update_external_order_applicant)
    end
  end
  
  def update?(resource)
    edit?(resource)
  end
  
  def destroy?(resource)
    if resource.solicitud? && resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:destroy_external_order_applicant)
    end
  end

  # def receive?
  #   dispense_pres.any? { |role| user.has_role?(role) }
  # end

  def receive_order?(resource)
    if resource.applicant_sector == user.sector && resource.provision_en_camino? 
      user.has_permission?(:receive_external_order_applicant)
    end
  end

  def edit_products?(resource)
    return unless resource.solicitud_auditoria? && resource.applicant_sector == user.sector
    user.has_permission?(:update_external_order_applicant) || create?
  end

  def can_send?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:send_external_order_applicant)
    end
  end

  def rollback_order?(resource)
    if resource.applicant_sector == user.sector && resource.solicitud_enviada?
      user.has_permission?(:return_external_order_applicant)
    end
  end

  # def edit_product?(resource)
  #   edit?(resource) && resource.persisted? && resource.added_by_sector_id.present? && resource.added_by_sector != user.sector
  # end

  def edit_provider_on_solicitud?(resource)
    if resource.solicitud? && resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:update_external_order_applicant)
    end
  end

end
