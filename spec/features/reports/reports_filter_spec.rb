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
      @reports = Report.all.sample(3)
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
        @reports.each do |report|
          within '#reports-filter' do
            fill_in 'filter[name]', with: report.name
            click_button 'Buscar'
          end
          sleep 1
          within 'tbody#reports' do
            expect(page.first('tr').has_css?('td', text: report.name)).to be true
          end
          within '#reports-filter' do
            first('button.btn-clean-filters').click
          end
          sleep 1
        end
      end

      it 'filter by sector name' do
        @reports.each do |report|
          within '#reports-filter' do
            fill_in 'filter[sector_name]', with: report.sector_name
            click_button 'Buscar'
          end
          sleep 1
          within 'tbody#reports' do
            expect(page.first('tr').has_css?('td', text: report.sector_name)).to be true
          end
          within '#reports-filter' do
            first('button.btn-clean-filters').click
          end
          sleep 1
        end
      end

      it 'filter by establishment name' do
        @reports.each do |report|
          within '#reports-filter' do
            fill_in 'filter[establishment_name]', with: report.establishment_name
            click_button 'Buscar'
          end
          sleep 1
          within 'tbody#reports' do
            expect(page.first('tr').has_css?('td', text: report.establishment_name)).to be true
          end
          within '#reports-filter' do
            first('button.btn-clean-filters').click
          end
          sleep 1
        end
      end

      it 'filter by generated date' do
        generated_date_filter = (DateTime.now - 2.day).strftime('%d/%m/%Y')
        within '#reports-filter' do
          fill_in 'filter[generated_date]', with: generated_date_filter
          click_button 'Buscar'
        end
        sleep 1
        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td')).to be true
        end
      end

      it 'filter by report type' do
        within '#reports-filter' do
          page.select 'Por paciente', from: 'filter[report_type]'
          click_button 'Buscar'
        end
        sleep 1
        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: 'Por paciente')).to be true
        end
      end
    end
  end
end
