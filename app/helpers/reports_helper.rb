module ReportsHelper
  # #This function show or hide element html
  ## based in a codition
  def select_report_type(type_report_selected, target_type)
    if type_report_selected != target_type
      'hidden'
    else
      ''
    end
  end
end
