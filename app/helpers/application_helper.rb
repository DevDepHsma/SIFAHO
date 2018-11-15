module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        flash_type.to_s
    end
  end
  def paginate(collection, params= {})
    will_paginate collection, params.merge(renderer: BootstrapPagination::Rails, previous_label: 'Atras', next_label: 'Siguiente')
  end
  def active_class(link_path)
    if params[:controller] == link_path
      return 'active'
    end 
  end
  def active_action(link_path)
    if params[:action] == link_path
      return 'active'
    end 
  end
  def order_status_label(an_order)
    if an_order.is_a?(Prescription)
      prescription_status_label(an_order)
    elsif an_order.is_a?(InternalOrder)
      internal_status_label(an_order)
    elsif an_order.is_a?(OrderingSupply)
      ordering_status_label(an_order)
    end
  end
end
