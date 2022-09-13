class Report < ApplicationRecord
  belongs_to :sector
  belongs_to :generated_by_user, class_name: 'User'

  enum report_type: { by_patient: 1 }
end
