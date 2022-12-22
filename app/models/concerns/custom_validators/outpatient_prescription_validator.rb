class CustomValidators::OutpatientPrescriptionValidator < ActiveModel::Validator
  def validate(record)
    puts record.outpatient_prescription_products.size
      puts "<================ validation".colorize(background: :blue)
    # Validate presence of at least 1 product
    if record.outpatient_prescription_products.size.zero?
      record.errors.add(:presence_of_products_into_the_order,
                        'Debe agregar almenos 1 producto')
    end

    # Validate prescribed date selected should be in a range
    unless record.date_prescribed >= (Date.today.months_ago(1)) && record.date_prescribed <= Date.today
      record.errors.add(:date_prescribed_in_range, 'Debe seleccionar una fecha válida')
    end

    # Validate duplicated products
    all_selected_products = record.outpatient_prescription_products.map(&:product_id)
    opps = all_selected_products.filter { |e| all_selected_products.count(e) > 1 }
    (record.outpatient_prescription_products.uniq - [self]).each do |opp|
      if opps.include?(opp.product_id) || true
        opp.errors.add(:uniqueness_product_in_the_order, 'Este producto ya se encuentra en la orden')
      end
    end
  end
end
