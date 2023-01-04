require 'rails_helper'

RSpec.feature 'ReportsBySectors', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Reportes')
    @report_by_sectors = permission_module.permissions.find_by(name: 'report_by_sectors')
    @read_reports = permission_module.permissions.find_by(name: 'read_reports')
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    describe 'Add permission' do
      it 'list' do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                              permission: @read_reports)
        visit '/'
        expect(page).to have_css('#sidebar-wrapper')
        within '#sidebar-wrapper' do
          expect(page).to have_link('Reportes')
          click_link 'Reportes'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Reportes')
        end
      end

      it 'Create: form and fields' do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                              permission: @read_reports)
        visit '/'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                              permission: @report_by_sectors)
        within '#sidebar-wrapper' do
          click_link 'Reportes'
        end
        within '#dropdown-menu-header' do
          click_link 'Nuevo reporte'
        end
        # By Sector
        expect(page).to have_content('Nuevo reporte')
        expect(page).to have_css('#new_report')
        i = 0
        within '#new_report' do
          Report.report_types.each do |type|
            expect(page).to have_content(I18n.t("activerecord.attributes.report.report_type.#{type[0]}")) if i == 1
            i += 1
          end
          expect(page).to have_content('Desde')
          expect(page).to have_content('Hasta')
          expect(page).to have_content('Productos')
          expect(page).to have_content('Sectores')

          expect(page).to have_field('report[name]', type: 'text')
          expect(page).to have_field('report[from_date]', type: 'text')
          expect(page).to have_field('report[to_date]', type: 'text')

          expect(page).to have_field('report[products_ids]', type: 'hidden')

          expect(page).to have_field('report[sectors_ids]', type: 'hidden')
          expect(page).to have_field('report[report_type]', type: 'radio', visible: false)

          expect(page).to have_field('products-search', type: 'text')
          expect(page).to have_field('sectors-search', type: 'text')
        end
      end
    end

    describe 'Form' do
      describe 'Products and Sectors fields with search and multi selection' do
        before(:each) do
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                                permission: @read_reports)
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                                permission: @report_by_sectors)
          visit '/reportes/nuevo'
          @reports_sectors = Sector.filter_by_internal_order({sector_id:@farm_applicant.active_sector}).sample(3)
          @sector = @reports_sectors.first
          @from_date = (DateTime.now - 1.year).strftime('%d/%m/%Y')
          @to_date = DateTime.now.strftime('%d/%m/%Y')
        end

        it 'Fill products' do
          within '#new_report' do
            @products.sample(5).each do |product|
              page.find('input#products-search').click.set(product.code)
              expect(page).to have_css('#products-collapse')
              within '#products-collapse' do
                expect(page).to have_button("#{product.code} | #{product.name.upcase}")
                click_button "#{product.code} | #{product.name.upcase}"
              end
              expect(page).to have_css('#selected-products')
              within '#selected-products' do
                expect(page).to have_button("#{product.code} | #{product.name.upcase}")
              end
            end
          end
        end

        it 'Fill sectors' do
          sleep 1
          within '#new_report' do
            # page.choose('by_sector')
            page.find('input#sectors-search').click.set(@sector.name)
            expect(page).to have_css('#sectors-collapse')
            within '#sectors-collapse' do
              expect(page).to have_button(@sector.name.to_s)
              click_button @sector.name.to_s
            end
            expect(page).to have_css('#selected-sectors')
            within '#selected-sectors' do
              expect(page).to have_button(@sector.name.to_s)
            end
          end
        end
      end

      describe 'Send' do
        before(:each) do
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                                permission: @read_reports)
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                                permission: @report_by_sectors)
          visit '/reportes/nuevo'
          @sample_products = @products.sample(5)
          @reports_sectors = Sector.filter_by_internal_order({sector_id:@farm_applicant.active_sector}).sample(3)
          @sector = @reports_sectors.first
          @from_date = (DateTime.now - 1.year).strftime('%d/%m/%Y')
          @to_date = DateTime.now.strftime('%d/%m/%Y')
        end

        it 'Success' do
          within '#new_report' do
            fill_in 'report[name]', with: 'Example report'
            page.find('label', text: 'Por sector').click
            fill_in 'report[from_date]', with: @from_date
            fill_in 'report[to_date]', with: @to_date
            # Product
            @products_to_dispense.each do |product|
              page.find('input#products-search').click.set(product.code)
              within '#products-collapse' do
                click_button "#{product.code} | #{product.name.upcase}"
              end
            end

            # Sector
            @reports_sectors.each do |sector|
              page.find('input#sectors-search').click.set(sector.name)
              within '#sectors-collapse' do
                click_button sector.name.to_s
              end
            end
          end
          click_button 'Guardar'
          expect(page).to have_content('Viendo reporte')
          expect(page).to have_link('Volver')
          expect(page).to have_link('Excel')
        end

        describe 'Fail and validations' do
          it 'displays required fields' do
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_css('input[name="report[name]"].is-invalid')
              expect(page.find('input[name="report[name]"]+.invalid-feedback')).to have_content('Nombre no puede estar en blanco')

              expect(page).to have_css('input[name="report[from_date]"].is-invalid')
              expect(page.find('input[name="report[from_date]"]+.invalid-feedback')).to have_content('Fecha desde no puede estar en blanco')

              expect(page).to have_css('input[name="report[to_date]"].is-invalid')
              expect(page.find('input[name="report[to_date]"]+.invalid-feedback')).to have_content('Fecha hasta no puede estar en blanco')

              expect(page).to have_css('input#products-search.is-invalid')
              expect(page).to have_content('Debe seleccionar almenos 1 producto')

              expect(page).to have_css('input#sectors-search.is-invalid')
              expect(page).to have_content('Debe seleccionar almenos 1 sector')
            end
          end

          it 'keep name attribute' do
            within '#new_report' do
              fill_in 'report[name]', with: 'Example report'
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_field('report[name]', with: 'Example report')
            end
          end

          it 'keep from_date attribute' do
            within '#new_report' do
              fill_in 'report[from_date]', with: @from_date
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_field('report[from_date]', with: @from_date)
            end
          end

          it 'keep to_date attribute' do
            within '#new_report' do
              fill_in 'report[to_date]', with: @to_date
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_field('report[to_date]', with: @to_date)
            end
          end

          it 'keep products attribute' do
            within '#new_report' do
              @sample_products.each do |product|
                page.find('input#products-search').click.set(product.code)
                within '#products-collapse' do
                  click_button "#{product.code} | #{product.name.upcase}"
                end
              end
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_field('report[products_ids]', type: 'hidden',
                                                                 with: @sample_products.pluck(:id).join('_'))
            end
            within '#selected-products' do
              @sample_products.each do |product|
                expect(page).to have_button("#{product.code} | #{product.name.upcase}")
              end
            end
          end

          it 'keep sectors attribute' do
            within '#new_report' do
              @reports_sectors.each do |sector|
                page.find('input#sectors-search').click.set(sector.name)
                within '#sectors-collapse' do
                  click_button sector.name.to_s
                end
              end
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_field('report[sectors_ids]', type: 'hidden',
                                                                with: @reports_sectors.pluck(:id).join('_'))
            end
            within '#selected-sectors' do
              @reports_sectors.each do |sector|
                expect(page).to have_button(sector.name.to_s)
              end
            end
          end

          it 'max products fails' do
            within '#new_report' do
              @products.sample(12).each do |product|
                page.find('input#products-search').click.set(product.code)
                within '#products-collapse' do
                  click_button "#{product.code} | #{product.name.upcase}"
                end
              end
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_css('input#products-search.is-invalid')
              expect(page).to have_content('No debe superar el máximo de 11 productos')
            end
          end

          it 'max sectors fails' do
            @reports_sectors = Sector.filter_by_internal_order({sector_id:@farm_applicant.active_sector}).sample(12)
            within '#new_report' do
              @reports_sectors.each do |sector|
                page.find('input#sectors-search').click.set(sector.name)
                within '#sectors-collapse' do
                  click_button sector.name.to_s
                end
              end
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_css('input#sectors-search.is-invalid')
              expect(page).to have_content('No debe superar el máximo de 11 sectores')
            end
          end
        end
      end
    end
  end
end
