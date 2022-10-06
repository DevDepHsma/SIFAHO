require 'rails_helper'

RSpec.feature 'Reports::ExternalOrderProductReports', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Reportes')
    @read_reports = permission_module.permissions.find_by(name: 'read_reports')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @read_reports)
  end

  background do
    sign_in_as(@farm_applicant)
  end
  describe 'Report Index', js: true do
    subject { page }

    before(:each) do
      visit '/reportes'
    end

    describe 'Form' do
      it 'fields' do
        expect(page.has_css?('#reports-filter')).to be true
        within '#reports-filter' do
          expect(page.has_field?('filter[name]', type: 'text')).to be true
          expect(page.has_field?('filter[sector_name]', type: 'text')).to be true
          expect(page.has_field?('filter[establishment_name]', type: 'text')).to be true
          expect(page.has_field?('filter[generated_date]', type: 'text')).to be true
          expect(page.has_select?('filter[report_type]')).to be true
          expect(page.has_button?('Buscar'))
          expect(page.has_css?('button.btn-clean-filters')).to be true
        end
      end

      it 'filter by name' do
        report = Report.all.sample
        within '#reports-filter' do
          fill_in 'filter[name]', with: report.name
          click_button 'Buscar'
        end
        # add expect
      end
    end
  end
end
