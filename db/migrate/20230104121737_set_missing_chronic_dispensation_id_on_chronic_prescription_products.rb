class SetMissingChronicDispensationIdOnChronicPrescriptionProducts < ActiveRecord::Migration[5.2]
  def change
    cds = ChronicDispensation.joins(:chronic_prescription_products).where('chronic_prescription_products.chronic_dispensation_id': nil)
    cds.each do |cd|
      cd.chronic_prescription_products.each do |cpp|
        cpp.chronic_dispensation_id = cd.id
        puts "<================ #{cpp.id} - #{cpp.chronic_dispensation_id} - #{ cd.id }".colorize(background: :red)
        cpp.save validate: false
      end
    end
  end
end
