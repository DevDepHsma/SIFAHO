def reports_populate
  get_by_patient.each do |report_name|
    report_params = { name: report_name,
                      report_type: 1,
                      product_ids: @products_to_dispense.pluck(:id).join('_'),
                      patient_ids: Patient.all.sample.id.to_s,
                      from_date: (DateTime.now - 1.month).strftime('%d/%m/%Y'),
                      to_date: DateTime.now.strftime('%d/%m/%Y') }
    Report.new.generate!(@farm_applicant, report_params)
  end
end
