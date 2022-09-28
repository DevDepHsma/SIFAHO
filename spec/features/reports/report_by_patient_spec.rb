require 'rails_helper'

RSpec.feature 'Reports::ExternalOrderProductReports', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Reportes')
    @report_by_patients = permission_module.permissions.find_by(name: 'report_by_patients')
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe '', js: true do
    subject { page }

    it 'No permissions' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe 'Add permission:' do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                              permission: @report_by_patients)
        visit '/'
      end

      it 'Reports permission' do
        expect(page.has_css?('#sidebar-wrapper')).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Reportes')).to be true
          click_link 'Reportes'
        end
        within '#dropdown-menu-header' do
          # expect(page.has_link?('Reportes')).to be true
        end

        # By Patient
        expect(page).to have_content('Nuevo reporte')
        expect(page.has_css?('#new_report')).to be true
        within '#new_report' do
          expect(page).to have_content('Desde')
          expect(page).to have_content('Hasta')
          expect(page).to have_content('Productos')
          expect(page).to have_content('Pacientes')
        end

      end
    end
  end
end
