def reports_populate
  get_by_patient.each do |report_name|
    report_params = { name: report_name,
                      report_type: 'by_patient',
                      products_ids: @products_to_dispense.pluck(:id).join('_'),
                      patients_ids: @patients.sample.id.to_s,
                      from_date: (DateTime.now - 1.month).strftime('%d/%m/%Y'),
                      to_date: DateTime.now.strftime('%d/%m/%Y') }
    Report.new.generate!(@farm_applicant, report_params)

    report_params = { name: report_name,
                      report_type: 'by_patient',
                      products_ids: @products_to_dispense.pluck(:id).join('_'),
                      patients_ids: @patients.sample.id.to_s,
                      from_date: (DateTime.now - 1.month).strftime('%d/%m/%Y'),
                      to_date: DateTime.now.strftime('%d/%m/%Y') }
    Report.new.generate!(@depo_applicant, report_params)

    report_params = { name: report_name,
                      report_type: 'by_patient',
                      products_ids: @products_to_dispense.pluck(:id).join('_'),
                      patients_ids: @patients.sample.id.to_s,
                      from_date: (DateTime.now - 1.month).strftime('%d/%m/%Y'),
                      to_date: DateTime.now.strftime('%d/%m/%Y') }
    Report.new.generate!(@farm_provider, report_params)
  end
end
