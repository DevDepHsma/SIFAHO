def patients_populate
  get_patients.each do |patient|
    create(:patient, dni: patient[0], sex: patient[1], last_name: patient[2], first_name: patient[3],
                     marital_status: patient[4])
  end
  @patients = Patient.all
end
