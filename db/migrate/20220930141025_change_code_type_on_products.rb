class ChangeCodeTypeOnProducts < ActiveRecord::Migration[5.2]
  def up 
    change_column :products, :code, 'integer USING CAST(code AS integer)'
  end

  def down 
    change_column :products, :code, 'varchar USING CAST(code AS varchar)'
  end
end
