class PurchasePolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    index?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    edit?
  end
  
  def edit?
    false
  end
  
  def set_products?
    record.inicial? || record.auditoria?
  end
  
  def save_products?
    set_products?
  end
  
  def receive_purchase?    
    record.auditoria?
  end
  
  def return_to_audit?
    # Estado RECIBIDO: se debe controlar que no halla superado las
    # 2 horas de recibido y controlar el rol del usuario
    if record.recibido? && record.received_date.present?
      diff_in_hours = (DateTime.now.to_time - record.received_date.to_time) / 1.hours
      if diff_in_hours < 2
        false
      end
    end
  end

  def return_to_audit_confirm?
    return_to_audit?
  end

  def destroy?
    false
  end

  def delete?
    destroy?
  end
end
