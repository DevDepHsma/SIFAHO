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
          expect(page.has_link?('Stock por rubro')).to be true
          expect(page.has_link?('Pacientes')).to be false
          expect(page.has_link?('Sectores')).to be false
          expect(page.has_link?('Establecimientos')).to be false
          expect(page.has_link?('Consumo por mes')).to be false
        end

        # Stock por rubro
        click_link 'Stock por rubro'
        expect(page).to have_content('Nuevo reporte de stock por rubro')
        expect(page).to have_content('Últimos reportes generados')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_button?('Generar')).to be true
      end
    end
  end
end
