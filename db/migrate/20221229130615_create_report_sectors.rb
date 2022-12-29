class CreateReportSectors < ActiveRecord::Migration[5.2]
  def up
    create_table :report_sectors do |t|
      t.integer  :report_id, index: true, foreign_key: { to_table: :reports }
      t.integer  :product_id, index: true, foreign_key: { to_table: :products }
      t.integer  :quantity
      t.string   :product_name
      t.integer  :product_code
      t.text     :description
      t.integer  :sector_id, index: true, foreign_key: { to_table: :sectors }
      t.string   :sector_name
      t.string   :order_type
      t.integer  :order_status, default: 0
      t.timestamps
    end
  end

  def down
    drop_table :report_sectors
  end
end
