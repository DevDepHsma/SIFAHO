class CreateProvinceReportPermission < ActiveRecord::Migration[5.2]
  def change
    reports = PermissionModule.find_by(name: 'Reportes')
    Permission.create(name: 'report_by_patient_and_province', permission_module: reports)
  end
end
