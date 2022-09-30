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

      # it 'Reports permission' do
      #   expect(page.has_css?('#sidebar-wrapper')).to be true
      #   within '#sidebar-wrapper' do
      #     expect(page.has_link?('Reportes')).to be true
      #     click_link 'Reportes'
      #   end
      #   within '#dropdown-menu-header' do
      #     expect(page.has_link?('Reportes')).to be true
      #   end
      # end
      describe 'Form' do
        before(:each) do
          within '#sidebar-wrapper' do
            click_link 'Reportes'
          end
        end

        # it 'Report labels / inputs' do
        #   # By Patient
        #   expect(page).to have_content('Nuevo reporte')
        #   expect(page.has_css?('#new_report')).to be true
        #   within '#new_report' do
        #     Report.report_types.each do |type|
        #       expect(page).to have_content(I18n.t("activerecord.attributes.report.report_type.#{type[0]}"))
        #     end
        #     expect(page).to have_content('Desde')
        #     expect(page).to have_content('Hasta')
        #     expect(page).to have_content('Productos')
        #     expect(page).to have_content('Pacientes')

        #     expect(page.has_field?('report[from_date]', type: 'text')).to be true
        #     expect(page.has_field?('report[to_date]', type: 'text')).to be true
        #     expect(page.has_field?('report[product_ids]', type: 'hidden')).to be true
        #     expect(page.has_field?('report[patient_ids]', type: 'hidden')).to be true
        #     expect(page.has_field?('report[report_type]', type: 'radio', visible: false)).to be true
        #     expect(page.has_field?('report[all_products]', type: 'checkbox', visible: false)).to be true
        #     expect(page.has_field?('report[all_patients]', type: 'checkbox', visible: false)).to be true

        #     expect(page.has_field?('products-search', type: 'text')).to be true
        #     expect(page.has_field?('patients-search', type: 'text')).to be true
        #   end
        # end

        describe 'Fill report form' do
          before(:each) do
            @product = Product.first
            @patient = Patient.first
          end
          it 'Fill products' do
            within '#new_report' do
              page.find('input#products-search').click.set(@product.code)
              sleep 1
              expect(page.has_css?('#products-collapse')).to be true

              within '#products-collapse' do
                expect(page.has_button?("#{@product.code} | #{@product.name}")).to be true
                click_button "#{@product.code} | #{@product.name}"
              end
              sleep 1
              expect(page.has_css?('#selected-products')).to be true
              within '#selected-products' do
                expect(page.has_button?("#{@product.code} | #{@product.name}")).to be true
              end
            end
          end
          
          it 'Fill patients' do
            within '#new_report' do
              page.find('input#patients-search').click.set(@patient.dni)
              sleep 1
              expect(page.has_css?('#patients-collapse')).to be true
sleep 10
              within '#patients-collapse' do
                expect(page.has_button?("#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}")).to be true
                click_button "#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}"
              end
              sleep 1
              expect(page.has_css?('#selected-patients')).to be true
              within '#selected-patients' do
                expect(page.has_button?("#{@patient.dni} | #{@patient.last_name.upcase} #{@patient.first_name.upcase}")).to be true
              end
            end
          end

          it 'Fill report form' do
            within '#new_report' do
              page.find('label', text: 'Por paciente').click
              fill_in 'report[from_date]', with: '01/01/2022'
              fill_in 'report[to_date]', with: Time.now.strftime('%d/%m/%Y')
            end
          end
        end
      end
    end
  end
end
