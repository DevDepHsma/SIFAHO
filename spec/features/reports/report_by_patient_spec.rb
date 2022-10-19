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

    describe 'Add permission' do
      it 'list' do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
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
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                              permission: @read_reports)
        visit '/'
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                              permission: @report_by_patients)
        within '#sidebar-wrapper' do
          click_link 'Reportes'
        end
        within '#dropdown-menu-header' do
          click_link 'Nuevo reporte'
        end
        # By Patient
        expect(page).to have_content('Nuevo reporte')
        expect(page).to have_css('#new_report')
        within '#new_report' do
          Report.report_types.each do |type|
            expect(page).to have_content(I18n.t("activerecord.attributes.report.report_type.#{type[0]}"))
          end
          expect(page).to have_content('Desde')
          expect(page).to have_content('Hasta')
          expect(page).to have_content('Productos')
          expect(page).to have_content('Pacientes')

          expect(page).to have_field('report[name]', type: 'text')
          expect(page).to have_field('report[from_date]', type: 'text')
          expect(page).to have_field('report[to_date]', type: 'text')

          expect(page).to have_field('report[products_ids]', type: 'hidden')

          expect(page).to have_field('report[patients_ids]', type: 'hidden')
          expect(page).to have_field('report[report_type]', type: 'radio', visible: false)

          expect(page).to have_field('products-search', type: 'text')
          expect(page).to have_field('patients-search', type: 'text')
        end
      end
    end

    describe 'Form' do
      describe 'Products and Patients fields with search and multi selection' do
        before(:each) do
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                permission: @read_reports)
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                permission: @report_by_patients)
          visit '/reportes/nuevo'
          @patients = Patient.all.sample(5)
          @patient = Patient.first
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

        it 'Fill patients' do
          within '#new_report' do
            page.find('input#patients-search').click.set(@patient.dni)
            expect(page).to have_css('#patients-collapse')
            within '#patients-collapse' do
              expect(page).to have_button("#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}")
              click_button "#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}"
            end
            expect(page).to have_css('#selected-patients')
            within '#selected-patients' do
              expect(page).to have_button("#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}")
            end
          end
        end
      end

      describe 'Send' do
        before(:each) do
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                permission: @read_reports)
          PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector,
                                permission: @report_by_patients)
          visit '/reportes/nuevo'
          @sample_products = @products.sample(5)
          @patients = Patient.all.sample(5)
          @patient = Patient.first
          @from_date = (DateTime.now - 1.year).strftime('%d/%m/%Y')
          @to_date = DateTime.now.strftime('%d/%m/%Y')
        end

        it 'Success' do
          within '#new_report' do
            fill_in 'report[name]', with: 'Example report'
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
            @patients.each do |patient|
              page.find('input#patients-search').click.set(patient.dni)
              within '#patients-collapse' do
                click_button "#{patient.dni} | #{patient.last_name.upcase} #{patient.first_name.upcase}"
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

              expect(page).to have_css('input#patients-search.is-invalid')
              expect(page).to have_content('Debe seleccionar almenos 1 paciente')
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

          it 'keep patients attribute' do
            within '#new_report' do
              @patients.each do |patient|
                page.find('input#patients-search').click.set(patient.dni)
                within '#patients-collapse' do
                  click_button "#{patient.dni} | #{patient.last_name.upcase} #{patient.first_name.upcase}"
                end
              end
            end
            click_button 'Guardar'
            within '#new_report' do
              expect(page).to have_field('report[patients_ids]', type: 'hidden',
                                                                 with: @patients.pluck(:id).join('_'))
            end
            within '#selected-patients' do
              @patients.each do |patient|
                expect(page).to have_button("#{patient.dni} | #{patient.last_name.upcase} #{patient.first_name.upcase}")
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

          # Require more patients records
          # it 'max patients fails' do
          #   @patients = Patient.all.sample(12)
          #   within '#new_report' do
          #     @patients.each do |patient|
          #       page.find('input#patients-search').click.set(patient.dni)
          #       within '#patients-collapse' do
          #         click_button "#{patient.dni} | #{patient.last_name.upcase} #{patient.first_name.upcase}"
          #       end
          #     end
          #   end
          #   click_button 'Guardar'
          #   within '#new_report' do
          #     sleep 10
          #     expect(page).to have_css('input#patients-search.is-invalid')
          #     expect(page).to have_content('No debe superar el máximo de 11 pacientes')
          #   end
          # end
        end
      end
    end
  end
end
