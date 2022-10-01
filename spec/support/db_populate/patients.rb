def patients_populate
  get_patients.each do |patient|
    create(:patient, dni: patient[0], sex: patient[1], last_name: patient[2], first_name: patient[3],
                     marital_status: patient[4])
  end
  @patients = Patient.all
end

def outpatient_prescriptions_populate
  @products_to_dispense = Product.all.sample(2)

  @patients.each_with_index do |patient, index|
    op = OutpatientPrescription.new(
      status: 'dispensada',
      date_dispensed: DateTime.now,
      professional_id: Professional.all.sample.id,
      patient_id: patient.id,
      provider_sector_id: @farm_applicant.sector_id,
      establishment_id: @farm_applicant.sector.establishment_id,
      remit_code: "AM#{DateTime.now.to_s(:number)}-#{index}",
      date_prescribed: DateTime.now
    )

    @products_to_dispense.each do |product|
      quantity = rand(2..5)
      opp = OutpatientPrescriptionProduct.new(
        product_id: product.id,
        request_quantity: quantity,
        delivery_quantity: quantity
      )

      opp.order_prod_lot_stocks.build({
                                        quantity: quantity,
                                        lot_stock_id: Stock.where(sector_id: @farm_applicant.sector_id,
                                                                  product_id: product.id).first.lot_stocks.first.id
                                      })

      op.outpatient_prescription_products << opp
    end
    op.save!
  end
end
