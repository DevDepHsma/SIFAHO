class Profile < ApplicationRecord
  enum sex: { indeterminado: 1, femenino: 2, masculino: 3 }
  enum theme: { light: 0, dark: 1 }
  enum sidebar_status: { show: 0, hide: 1 }

  #Relaciones
  belongs_to :user
  has_one_attached :avatar

  validates :avatar, content_type: ['image/png', 'image/jpg', 'image/jpeg']

  def full_name
    "#{last_name} #{first_name}"
  end
end
