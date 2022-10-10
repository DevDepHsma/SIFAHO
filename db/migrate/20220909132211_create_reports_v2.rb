class CreateReportsV2 < ActiveRecord::Migration[5.2]
  def up
    # Drop old table and its foreign_keys
    drop_table :reports, if_exists: true

    create_table :reports do |t|
      t.references :sector, index: true, foreign_key: {to_table: :sectors}
      t.string :name
      t.string :sector_name
      t.string :establishment_name
      t.datetime :generated_date
      t.datetime :from_date
      t.datetime :to_date
      t.string :product_ids
      t.string :patient_ids
      t.references :generated_by_user, index: true, foreign_key: {to_table: :users}
      t.integer :report_type, default: 0

    end
  end

  def down
    drop_table :reports
  end
end
