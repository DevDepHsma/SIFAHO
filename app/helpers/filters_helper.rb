module FiltersHelper

  def get_value_from_filter(param)
    params[:filter].present? && params[:filter][param].present? ? params[:filter][param] : ''
  end
end
