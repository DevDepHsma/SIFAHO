class AddProductAndOutpatientPrescriptionIndexToOutpatientPrescriptionProduct < ActiveRecord::Migration[5.2]
  def change
    remove_index :outpatient_prescription_products, name: "unique_out_pres_prod_on_outpatient_prescriptions"
    remove_index :outpatient_prescription_products, name: "index_outpatient_prescription_products_on_product_id"

    add_index :outpatient_prescription_products, [:outpatient_prescription_id, :product_id], unique: true, :name => 'unique_product_on_op_products'
  end
end
