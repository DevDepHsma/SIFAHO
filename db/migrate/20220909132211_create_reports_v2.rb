class CreateReportsV2 < ActiveRecord::Migration[5.2]
  def up
    # Drop old table and its foreign_keys
    drop_table :reports, if_exists: true

    create_table :reports do |t|
      t.references :sector, index: true, foreign_key: {to_table: :sectors}
      t.string :name
      t.string :sector_name
      t.string :establishment_name
      t.datetime :generated_name
      t.references :generated_by_user, index: true, foreign_key: {to_table: :users}
      t.integer :report_type
    end
  end

  def down
    drop_table :reports
  end
end
