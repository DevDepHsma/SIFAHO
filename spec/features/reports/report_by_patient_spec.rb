require 'rails_helper'

RSpec.feature 'Reports::CreateAndShow', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Reportes')
    @report_by_patients = permission_module.permissions.find_by(name: 'report_by_patients')
    @read_reports = permission_module.permissions.find_by(name: 'read_reports')
    @destroy_reports = permission_module.permissions.find_by(name: 'destroy_reports')
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
                              permission: @read_reports)
        visit '/'
      end

      it 'Reports permission' do
        expect(page.has_css?('#sidebar-wrapper')).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Reportes')).to be true
          click_link 'Reportes'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Reportes')).to be true
        end
      end
      describe 'Form' do
        before(:each) do
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                permission: @report_by_patients)
          within '#sidebar-wrapper' do
            click_link 'Reportes'
          end
          within '#dropdown-menu-header' do
            click_link 'Nuevo reporte'
          end
        end

        it 'Report labels / inputs' do
          # By Patient
          expect(page).to have_content('Nuevo reporte')
          expect(page.has_css?('#new_report')).to be true
          within '#new_report' do
            Report.report_types.each do |type|
              expect(page).to have_content(I18n.t("activerecord.attributes.report.report_type.#{type[0]}"))
            end
            expect(page).to have_content('Desde')
            expect(page).to have_content('Hasta')
            expect(page).to have_content('Productos')
            expect(page).to have_content('Pacientes')

            expect(page.has_field?('report[from_date]', type: 'text')).to be true
            expect(page.has_field?('report[to_date]', type: 'text')).to be true
            expect(page.has_field?('report[product_ids]', type: 'hidden')).to be true
            expect(page.has_field?('report[patient_ids]', type: 'hidden')).to be true
            expect(page.has_field?('report[report_type]', type: 'radio', visible: false)).to be true
            expect(page.has_field?('report[all_products]', type: 'checkbox', visible: false)).to be true
            expect(page.has_field?('report[all_patients]', type: 'checkbox', visible: false)).to be true

            expect(page.has_field?('products-search', type: 'text')).to be true
            expect(page.has_field?('patients-search', type: 'text')).to be true
          end
        end

        describe 'Fill report form' do
          before(:each) do
            @products = Product.all.sample(5)
            @patient = Patient.first
            @from_date = (DateTime.now - 1.year).strftime('%d/%m/%Y')
            @to_date = DateTime.now.strftime('%d/%m/%Y')
          end

          it 'Fill products' do
            within '#new_report' do
              @products.each do |product|
                page.find('input#products-search').click.set(product.code)
                expect(page.has_css?('#products-collapse')).to be true
                within '#products-collapse' do
                  expect(page.has_button?("#{product.code} | #{product.name.upcase}")).to be true
                  click_button "#{product.code} | #{product.name.upcase}"
                end
                expect(page.has_css?('#selected-products')).to be true
                within '#selected-products' do
                  expect(page.has_button?("#{product.code} | #{product.name.upcase}")).to be true
                end
              end
            end
          end

          it 'Fill patients' do
            within '#new_report' do
              page.find('input#patients-search').click.set(@patient.dni)
              expect(page.has_css?('#patients-collapse')).to be true
              within '#patients-collapse' do
                expect(page.has_button?("#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}")).to be true
                click_button "#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}"
              end
              expect(page.has_css?('#selected-patients')).to be true
              within '#selected-patients' do
                expect(page.has_button?("#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}")).to be true
              end
            end
          end

          it 'Fill dates and report type' do
            within '#new_report' do
              page.find('label', text: 'Por paciente').click
              fill_in 'report[from_date]', with: @from_date
              fill_in 'report[to_date]', with: @to_date
            end
          end

          it 'Send success form' do
            within '#new_report' do
              page.find('label', text: 'Por paciente').click
              fill_in 'report[from_date]', with: @from_date
              fill_in 'report[to_date]', with: @to_date
              # Product
              @products_to_dispense.each do |product|
                page.find('input#products-search').click.set(product.code)
                within '#products-collapse' do
                  click_button "#{product.code} | #{product.name.upcase}"
                end
              end
              # Patient
              within '#patients-module' do
                page.find('label', text: 'Todos').click
              end
            end
            click_button 'Guardar'
            expect(page).to have_content('Viendo reporte')
            expect(page.has_link?('Volver')).to be true
            expect(page.has_link?('Excel')).to be true
          end
        end
      end
    end
  end
end
