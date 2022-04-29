class InternalOrderApplicantPolicy < ApplicationPolicy

  def index?
    show?
  end

  def show?
    user.has_permission?(:read_internal_order_applicant)
  end

  def new?
    user.has_permission?(:create_internal_order_applicant)
  end

  def new_report?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def create?
    new?
  end

  def edit?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:update_internal_order_applicant)
    end
  end

  def edit_products?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:update_internal_order_applicant) || create?
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def can_send?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:send_internal_order_applicant)
    end
  end

  def destroy?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_permission?(:destroy_internal_order_applicant)
    end
  end

  def generate_report?
    new_report?
  end

  def receive_order?(resource)
    if resource.applicant_sector == user.sector && resource.provision_en_camino?
      user.has_permission?(:receive_internal_order_applicant)
    end
  end

  def rollback_order?(resource)
    if resource.applicant_sector == user.sector && resource.solicitud_enviada?
      user.has_permission?(:return_internal_order_applicant)
    end
  end
end
