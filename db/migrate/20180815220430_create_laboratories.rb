class CreateLaboratories < ActiveRecord::Migration[5.1]
  def change
    create_table :laboratories do |t|
      t.bigint :cuit, index: { unique: true }
      t.bigint :gln, index: { unique: true }
      t.string :name
    end
    add_reference :supply_lots, :laboratory, foreign_key: true
  end
end
