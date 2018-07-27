class Profile < ApplicationRecord
  enum sex: { indeterminado: 1, mujer: 2, hombre: 3 }

  #Relaciones
  belongs_to :user

  def full_name
    self.last_name+" "+self.first_name
  end
end
