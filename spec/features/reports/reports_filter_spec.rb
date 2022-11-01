require 'rails_helper'

RSpec.feature 'Reports::IndexAndFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Reportes')
    @read_reports = permission_module.permissions.find_by(name: 'read_reports')
    @destroy_reports = permission_module.permissions.find_by(name: 'destroy_reports')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @read_reports)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                          permission: @destroy_reports)
  end

  background do
    sign_in @farm_applicant
  end
  describe 'Report Index', js: true do
    subject { page }

    before(:each) do
      visit '/reportes'
      @reports = Report.all.sample(3)
    end

    describe 'Filter Form' do
      it 'fields' do
        expect(page).to have_css('#reports-filter')
        within '#reports-filter' do
          expect(page).to have_field('filter[name]', type: 'text')
          expect(page).to have_field('filter[sector_name]', type: 'text')
          expect(page).to have_field('filter[establishment_name]', type: 'text')
          expect(page).to have_field('filter[generated_date]', type: 'text')
          expect(page).to have_select('filter[report_type]')
          expect(page).to have_button('Buscar')
          expect(page).to have_css('button.btn-clean-filters')
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
            expect(page.first('tr')).to have_selector('td', text: report.name)
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
            expect(page.first('tr')).to have_selector('td', text: report.sector_name)
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
            expect(page.first('tr')).to have_selector('td', text: report.establishment_name)
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
          expect(page.first('tr')).to have_selector('td')
        end
      end

      it 'filter by report type' do
        within '#reports-filter' do
          page.select 'Por paciente', from: 'filter[report_type]'
          click_button 'Buscar'
        end
        sleep 1
        within 'tbody#reports' do
          expect(page.first('tr')).to have_selector('td', text: 'Por paciente')
        end
      end
    end

    describe 'Pagination' do
      before(:each) do
        @last_page = (Report.all.count / 15.to_f).ceil
      end

      it 'has pagination' do
        within '#paginate_footer nav' do
          expect(page).to have_selector('a.page-link', text: @last_page.to_s)
        end
      end

      it 'has pagination size selector' do
        within '#paginate_footer' do
          expect(page).to have_select('page-size-selection', with_options: %w[15 30 50 100])
        end
      end

      it 'change page number' do
        within '#paginate_footer nav' do
          expect(page).to have_selector('li.active', text: '1')
          click_link @last_page.to_s
          sleep 1
          expect(page).to have_selector('li.active', text: @last_page.to_s)
        end
      end

      it 'has 15 items per page by default' do
        within '#reports' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#reports' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Nombre')
          expect(page).to have_button('Sector nombre')
          expect(page).to have_button('Establecimiento nombre')
          expect(page).to have_button('Generado')
          expect(page).to have_button('Tipo')
        end
      end

      it 'by "nombre"' do
        sorted_by_name_asc = Report.order(name: :asc).first
        sorted_by_name_desc = Report.order(name: :desc).first

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_name_asc.name)
        end

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_name_desc.name)
        end
      end

      it 'by "Sector nombre"' do
        sorted_by_sector_name_asc = Report.order(sector_name: :asc).first
        sorted_by_sector_name_desc = Report.order(sector_name: :desc).first

        within '#table_results' do
          click_button 'Sector nombre'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_content(sorted_by_sector_name_asc.sector_name)
        end

        within '#table_results' do
          click_button 'Sector nombre'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_content(sorted_by_sector_name_desc.sector_name)
        end
      end

      it 'by "Establecimiento nombre"' do
        sorted_by_establishment_name_asc = Report.order(establishment_name: :asc).first
        sorted_by_establishment_name_desc = Report.order(establishment_name: :desc).first

        within '#table_results' do
          click_button 'Establecimiento nombre'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(3)')).to have_content(sorted_by_establishment_name_asc.establishment_name)
        end

        within '#table_results' do
          click_button 'Establecimiento nombre'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(3)')).to have_content(sorted_by_establishment_name_desc.establishment_name)
        end
      end

      it 'by "Generado"' do
        sorted_by_generated_date_asc = Report.order(generated_date: :asc).first
        sorted_by_generated_date_desc = Report.order(generated_date: :desc).first

        within '#table_results' do
          click_button 'Generado'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(4)')).to have_content(sorted_by_generated_date_asc.generated_date.strftime('%d/%m/%Y'))
        end

        within '#table_results' do
          click_button 'Generado'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(4)')).to have_content(sorted_by_generated_date_desc.generated_date.strftime('%d/%m/%Y'))
        end
      end

      it 'by "Tipo"' do
        sorted_by_report_type_asc = Report.order(report_type: :asc).first
        sorted_by_report_type_desc = Report.order(report_type: :desc).first

        within '#table_results' do
          click_button 'Tipo'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(5)')).to have_content(I18n.t("activerecord.attributes.report.report_type.#{sorted_by_report_type_asc.report_type}"))
        end

        within '#table_results' do
          click_button 'Tipo'
          sleep 1
        end

        within '#reports' do
          expect(page.first('tr').find('td:nth-child(5)')).to have_content(I18n.t("activerecord.attributes.report.report_type.#{sorted_by_report_type_desc.report_type}"))
        end
      end
    end

    describe 'Destroy permission' do
      before(:each) do
        @report_to_del = Report.all.sample
        within '#reports-filter' do
          fill_in 'filter[name]', with: @report_to_del.name
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button destroy' do
        within '#reports' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#reports' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar reporte')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy items' do
        within '#reports' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text("El reporte #{@report_to_del.name} se ha eliminado correctamente.")
      end
    end
  end
end
