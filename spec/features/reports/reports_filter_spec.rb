require 'rails_helper'

RSpec.feature 'Reports::IndexAndFilters', type: :feature do
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

    describe 'Filter Form' do
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

    describe 'Pagination' do
      it 'displays pagination' do
        expect(page.has_css?('#paginate_footer')).to be true
        expect(page.has_select?('page-size-selection')).to be true
      end

      it 'Total page' do
        reports_count = Report.all.count
        page_size = (reports_count / 15.to_f).ceil
        within '#paginate_footer nav' do
          expect(page.has_link?(page_size.to_s)).to be true
          expect(page.has_link?((page_size + 1).to_s)).not_to be true
        end
      end

      it 'changes page size' do
        reports_count = Report.all.count
        page_size = (reports_count / 15.to_f).ceil

        within 'tbody#reports' do
          expect(page.has_css?('tr', count: 15)).to be true
        end
        within '#paginate_footer' do
          within 'nav' do
            expect(page.has_link?(page_size.to_s)).to be true
            expect(page.has_link?((page_size + 1).to_s)).not_to be true
          end
          page.select '30', from: 'page-size-selection'
        end

        page_size = (reports_count / 30.to_f).ceil
        within 'tbody#reports' do
          expect(page.has_css?('tr', count: 30)).to be true
        end
        within '#paginate_footer' do
          within 'nav' do
            expect(page.has_link?(page_size.to_s)).to be true
            expect(page.has_link?((page_size + 1).to_s)).not_to be true
          end
        end
      end
    end

    describe 'Sort' do
      it 'displays soting buttons' do
        within '#table_results thead' do
          expect(page.has_button?('Nombre')).to be true
          expect(page.has_button?('Sector nombre')).to be true
          expect(page.has_button?('Establecimiento nombre')).to be true
          expect(page.has_button?('Generado')).to be true
          expect(page.has_button?('Tipo')).to be true
        end
      end

      it 'sort by "nombre"' do
        sort_by_name_asc = Report.order(name: :asc).first
        within '#table_results thead' do
          click_button 'Nombre'
        end
        sleep 1
        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: sort_by_name_asc.name)).to be true
        end

        sort_by_name_desc = Report.order(name: :desc).first
        within '#table_results thead' do
          click_button 'Nombre'
        end
        sleep 1
        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: sort_by_name_desc.name)).to be true
        end
      end

      it 'sort by "Sector nombre"' do
        sort_by_sector_name_asc = Report.order(sector_name: :asc).first
        within '#table_results thead' do
          click_button 'Sector nombre'
        end
        sleep 1
        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: sort_by_sector_name_asc.sector_name)).to be true
        end

        sort_by_sector_name_desc = Report.order(sector_name: :desc).first
        within '#table_results thead' do
          click_button 'Sector nombre'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: sort_by_sector_name_desc.sector_name)).to be true
        end
      end

      it 'sort by "Establecimiento nombre"' do
        sort_by_establishment_name_asc = Report.order(establishment_name: :asc).first
        within '#table_results thead' do
          click_button 'Establecimiento nombre'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: sort_by_establishment_name_asc.establishment_name)).to be true
        end

        sort_by_establishment_name_desc = Report.order(establishment_name: :desc).first
        within '#table_results thead' do
          click_button 'Establecimiento nombre'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td', text: sort_by_establishment_name_desc.establishment_name)).to be true
        end
      end

      it 'sort by "Generado"' do
        sort_by_generated_date_asc = Report.order(generated_date: :asc).first
        within '#table_results thead' do
          click_button 'Generado'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td',
                                           text: sort_by_generated_date_asc.generated_date.strftime('%d/%m/%Y'))).to be true
        end

        sort_by_generated_date_desc = Report.order(generated_date: :desc).first
        within '#table_results thead' do
          click_button 'Generado'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td',
                                           text: sort_by_generated_date_desc.generated_date.strftime('%d/%m/%Y'))).to be true
        end
      end

      it 'sort by "Tipo"' do
        sort_by_report_type_asc = Report.order(report_type: :asc).first
        within '#table_results thead' do
          click_button 'Tipo'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td',
                                           text: I18n.t("activerecord.attributes.report.report_type.#{sort_by_report_type_asc.report_type}"))).to be true
        end

        sort_by_report_type_desc = Report.order(report_type: :desc).first
        within '#table_results thead' do
          click_button 'Tipo'
        end
        sleep 1

        within 'tbody#reports' do
          expect(page.first('tr').has_css?('td',
                                           text: I18n.t("activerecord.attributes.report.report_type.#{sort_by_report_type_desc.report_type}"))).to be true
        end
      end
    end
  end
end
