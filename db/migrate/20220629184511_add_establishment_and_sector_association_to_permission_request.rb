class AddEstablishmentAndSectorAssociationToPermissionRequest < ActiveRecord::Migration[5.2]
  def up
    add_reference :permission_requests, :estalbishment, foreign_key: { to_table: :establihments }
  end

  def down 
    remove_column :permission_requests, :estalbishment    
  end
end
