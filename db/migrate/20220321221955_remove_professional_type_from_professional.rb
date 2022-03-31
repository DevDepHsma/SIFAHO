class RemoveProfessionalTypeFromProfessional < ActiveRecord::Migration[5.2]
  def up
    remove_reference :professionals, :professional_type, index: true
  end
  
  def down
    add_reference :professionals, :professional_type, index: true, default: 5
  end
end
