# == Test Information

#  Testing modules:
#  Filter: fields and results
#  Pagination: presence and results
#  Sort: buttons and results
#  Destroy action
#  Return action
#  Dispense action
#  End treatment action
#

require 'rails_helper'

RSpec.feature 'Prescriptions::ChronicPrescriptionsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Crónicas')
    @read_chronic_recipe_permission = permission_module.permissions.find_by(name: 'read_chronic_prescriptions')
    @dispense_chronic_recipe_permission = permission_module.permissions.find_by(name: 'dispense_chronic_prescriptions')
    @return_chronic_recipe_permission = permission_module.permissions.find_by(name: 'return_chronic_prescriptions')
    @complete_treatment_chronic_recipe_permission = permission_module.permissions.find_by(name: 'complete_treatment_chronic_prescriptions')
    @destroy_chronic_recipe_permission = permission_module.permissions.find_by(name: 'destroy_chronic_prescriptions')
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.active_sector,
                          permission: @read_chronic_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.active_sector,
                          permission: @destroy_chronic_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.active_sector,
                          permission: @dispense_chronic_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.active_sector,
                          permission: @return_chronic_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.active_sector,
                          permission: @complete_treatment_chronic_recipe_permission)
  end

  background do
    sign_in @farm_provider
  end

  describe '', js: true do
    subject { page }

    before(:each) do
      visit '/recetas/cronicas'
      @cp_prescriptions = ChronicPrescription.all.sample(5)
    end

    describe 'form filter' do
      it 'has fields' do
        within '#chronic-prescriptions-filter' do
          expect(page).to have_field('filter[code]', type: 'text')
          expect(page).to have_field('filter[professional_full_name]', type: 'text')
          expect(page).to have_field('filter[patient_full_name]', type: 'text')
          expect(page).to have_field('filter[date_prescribed_since]', type: 'text')
          expect(page).to have_field('filter[date_prescribed_to]', type: 'text')
          expect(page).to have_select('filter[status]', with_options: %w[pendiente dispensada vencida])
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end

      it 'by remit_code' do
        @cp_prescriptions.each do |opp|
          within '#chronic-prescriptions-filter' do
            fill_in 'filter[code]', with: opp.remit_code
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').first('td')).to have_selector('mark.highlight', text: opp.remit_code)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by professional fullname' do
        @cp_prescriptions.each do |opp|
          # By first name
          within '#chronic-prescriptions-filter' do
            fill_in 'filter[professional_full_name]', with: opp.professional.first_name
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1',
                                                                              text: opp.professional.first_name)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
          # By last name
          within '#chronic-prescriptions-filter' do
            fill_in 'filter[professional_full_name]', with: opp.professional.last_name
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1',
                                                                              text: opp.professional.last_name)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by patient full_name' do
        @cp_prescriptions.each do |opp|
          within '#chronic-prescriptions-filter' do
            # By dni
            fill_in 'filter[patient_full_name]', with: opp.patient.dni
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_selector('mark.highlight-2',
                                                                              text: opp.patient.dni)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
          # By first name
          within '#chronic-prescriptions-filter' do
            fill_in 'filter[patient_full_name]', with: opp.patient.first_name
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_selector('mark.highlight-2',
                                                                              text: opp.patient.first_name)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
          # By last name
          within '#chronic-prescriptions-filter' do
            fill_in 'filter[patient_full_name]', with: opp.patient.last_name
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_selector('mark.highlight-2',
                                                                              text: opp.patient.last_name)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by date_prescribed_since and date_prescribed_to' do
        @cp_prescriptions.each do |opp|
          within '#chronic-prescriptions-filter' do
            fill_in 'filter[date_prescribed_since]', with: opp.date_prescribed.strftime('%d/%m/%Y')
            fill_in 'filter[date_prescribed_to]', with: opp.date_prescribed.strftime('%d/%m/%Y')
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(6)')).to have_content(opp.date_prescribed.strftime('%d/%m/%Y'))
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by status' do
        @cp_prescriptions.each do |opp|
          within '#chronic-prescriptions-filter' do
            page.select opp.status, from: 'filter[status]'
            click_button 'Buscar'
            sleep 1
          end
          within '#chronic_prescriptions' do
            expect(page.first('tr').find('td:nth-child(4)')).to have_content(opp.status.underscore.humanize)
          end
          within '#chronic-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end # describe form filter

    describe 'pagination' do
      before(:each) do
        @last_page = (ChronicPrescription.all.count / 15.to_f).ceil
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
        within '#chronic_prescriptions' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#chronic_prescriptions' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end # Describe pagination

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Médico')
          expect(page).to have_button('Paciente')
          expect(page).to have_button('Recetada')
        end
      end

      it 'by professional' do
        sorted_by_professional_asc = ChronicPrescription.select('professionals.fullname AS pr_fullname').joins(:professional).order('pr_fullname asc').first
        sorted_by_professional_desc = ChronicPrescription.select('professionals.fullname AS pr_fullname').joins(:professional).order('pr_fullname desc').first

        within '#table_results' do
          click_button 'Médico'
          sleep 1
        end

        within '#chronic_prescriptions' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_content(sorted_by_professional_asc.pr_fullname)
        end

        within '#table_results' do
          click_button 'Médico'
          sleep 1
        end

        within '#chronic_prescriptions' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_content(sorted_by_professional_desc.pr_fullname)
        end
      end

      it 'by name' do
        sorted_by_patient_asc = ChronicPrescription.select('patients.first_name AS pa_first_name',
                                                              'patients.last_name AS pa_last_name', 'patients.dni AS pa_dni').joins(:patient).order('pa_last_name asc').first
        sorted_by_patient_desc = ChronicPrescription.select('patients.first_name AS pa_first_name',
                                                               'patients.last_name AS pa_last_name', 'patients.dni AS pa_dni').joins(:patient).order('pa_last_name desc').first

        within '#table_results' do
          click_button 'Paciente'
          sleep 1
        end

        within '#chronic_prescriptions' do
          expect(page.first('tr').find('td:nth-child(3)')).to have_text(sorted_by_patient_asc.pa_last_name)
        end

        within '#table_results' do
          click_button 'Paciente'
          sleep 1
        end

        within '#chronic_prescriptions' do
          expect(page.first('tr').find('td:nth-child(3)')).to have_text(sorted_by_patient_desc.pa_last_name)
        end
      end

      it 'by date prescribed' do
        sorted_by_date_prescribed_asc = ChronicPrescription.select(:date_prescribed).order('date_prescribed asc').first
        sorted_by_date_prescribed_desc = ChronicPrescription.select(:date_prescribed).order('date_prescribed desc').first

        within '#table_results' do
          click_button 'Recetada'
          sleep 1
        end

        within '#chronic_prescriptions' do
          expect(page.first('tr').find('td:nth-child(6)')).to have_text(sorted_by_date_prescribed_asc.date_prescribed.strftime('%d/%m/%Y'))
        end

        within '#table_results' do
          click_button 'Recetada'
          sleep 1
        end

        within '#chronic_prescriptions' do
          expect(page.first('tr').find('td:nth-child(6)')).to have_text(sorted_by_date_prescribed_desc.date_prescribed.strftime('%d/%m/%Y'))
        end
      end
    end # describe sort

    describe 'Destroy permission' do
      before(:each) do
        @chronic_prescription_to_del = ChronicPrescription.where(status: 'pendiente').sample
        within '#chronic-prescriptions-filter' do
          fill_in 'filter[code]', with: @chronic_prescription_to_del.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button destroy' do
        within '#chronic_prescriptions' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#chronic_prescriptions' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar prescripción')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy items' do
        within '#chronic_prescriptions' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text("La receta de #{@chronic_prescription_to_del.professional.fullname} se ha eliminado correctamente.")
      end
    end # describe destroy

    describe 'Return permission' do
      before(:each) do
        @chronic_prescription_to_return = ChronicPrescription.where(status: 'dispensada').sample
        within '#chronic-prescriptions-filter' do
          fill_in 'filter[code]', with: @chronic_prescription_to_return.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button show' do
        within '#chronic_prescriptions' do
          expect(page).to have_selector('a.btn-detail')
        end
      end

      it 'show and dispensations' do
        within '#chronic_prescriptions' do
          page.first('a.btn-detail').click
        end
        click_link 'Dispensaciones'
        within '#list-tab' do
          @chronic_prescription_to_return.chronic_dispensations.each_with_index do |cd, index|
            expect(page).to have_selector("#list-dispensation-#{index}",
                                          text: cd.created_at.strftime('%d/%m/%Y %H:%M').to_s)
          end
        end
        expect(page).to have_selector('thead tr th', text: 'Cód Ins')
        expect(page).to have_selector('thead tr th', text: 'Insumo')
        expect(page).to have_selector('thead tr th', text: 'Unidad')
        expect(page).to have_selector('thead tr th', text: 'Entregado')
        expect(page).to have_selector('thead tr th', text: 'Productos')
        expect(page).to have_selector('thead tr th', text: 'Observaciones')
      end

      it 'return prescription' do
        visit "/recetas/cronicas/#{@chronic_prescription_to_return.id}"
        click_link 'Dispensaciones'
        within '#list-tab' do
          page.first('a.return-dispensation-modal').click
          sleep 1
        end

        within '#return-confirm' do
          expect(page).to have_content('Retornar y eliminar dispensación con fecha')
          expect(page).to have_content('Se volverán a stock los siguientes productos:')
          expect(page).to have_content('Está seguro de que desea retornar?')
          expect(page).to have_link('Cancelar')
          expect(page).to have_link('Continuar')
          click_link 'Continuar'
          sleep 1
        end
        expect(page).to have_content("La receta de #{@chronic_prescription_to_return.professional.fullname} se ha retornado una dispensa correctamente.")
      end
    end # describe return dispensation

    describe 'Dispense' do
      before(:each) do
        @chronic_prescription_to_dispense = ChronicPrescription.where(status: 'dispensada_parcial').sample
        within '#chronic-prescriptions-filter' do
          fill_in 'filter[code]', with: @chronic_prescription_to_dispense.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button show' do
        within '#chronic_prescriptions' do
          expect(page).to have_selector('a.btn-dispense')
        end
      end

      it 'has dispense button' do
        visit "recetas/cronicas/#{@chronic_prescription_to_dispense.id}/dispensar/nuevo"
        expect(page).to have_content("Dispensar receta crónica: #{@chronic_prescription_to_dispense.patient.fullname.titleize}")
        expect(page).to have_content('Médico')
        expect(page).to have_content(@chronic_prescription_to_dispense.professional.fullname.titleize.to_s)
        expect(page).to have_content('Paciente')
        expect(page).to have_content(@chronic_prescription_to_dispense.patient.fullname.titleize.to_s)
        expect(page).to have_content('Dni')
        expect(page).to have_content(@chronic_prescription_to_dispense.patient.dni.to_s)
        expect(page).to have_content('Fecha recetada')
        expect(page).to have_content(@chronic_prescription_to_dispense.date_prescribed.strftime('%d/%m/%Y').to_s)
        expect(page).to have_content('Duración de tratamiento')
        expiry_date_in_month = (@chronic_prescription_to_dispense.expiry_date.year * 12 + @chronic_prescription_to_dispense.expiry_date.month)
        date_prescribed_in_month = (@chronic_prescription_to_dispense.date_prescribed.year * 12 + @chronic_prescription_to_dispense.date_prescribed.month)
        expect(page).to have_content("#{expiry_date_in_month - date_prescribed_in_month} meses")
        expect(page).to have_content('Fecha vencimiento')
        expect(page).to have_content(@chronic_prescription_to_dispense.expiry_date.strftime('%d/%m/%Y').to_s)
        expect(page).to have_content('Diagnóstico')
        expect(page).to have_content(@chronic_prescription_to_dispense.diagnostic.to_s)

        within '#new_chronic_dispensation' do
          @chronic_prescription_to_dispense.original_chronic_prescription_products.each do |ocpp|
            expect(page).to have_selector('td', text: ocpp.product.name)
            expect(page).to have_selector('td', text: ocpp.request_quantity)
            expect(page).to have_selector('td', text: (ocpp.total_request_quantity - ocpp.total_delivered_quantity))
            expect(page).to have_selector('td a', class: 'btn-asign-product')
          end
        end

        expect(page).to have_link('Volver')
        expect(page).to have_button('Dispensar')
      end

      it 'dispense' do
        visit "recetas/cronicas/#{@chronic_prescription_to_dispense.id}/dispensar/nuevo"
        ocpp = @chronic_prescription_to_dispense.original_chronic_prescription_products.sample
        within '#new_chronic_dispensation' do
          page.first('tr', text: ocpp.product.name).first('a.btn-asign-product').click
          expect(page).to have_field('product_code_fake-', type: 'text', with: ocpp.product.code)
          expect(page).to have_field('product_name_fake-', type: 'text', with: ocpp.product.name)
          expect(page).to have_selector("input[type='text'][disabled='disabled'][value='#{ocpp.product.unity.name}']")
          expect(page).to have_button('Seleccionados 0')

          page.first('input.deliver-quantity').set(ocpp.request_quantity)
          click_button 'Seleccionados 0'
          sleep 1
        end
        within '#lot-selection' do
          expect(page).to have_content('Seleccionar lote en stock')
          expect(page).to have_field('lot-quantity[0]', type: 'number')
          expect(page).to have_button('Volver')
          fill_in 'lot-quantity[0]', with: ocpp.request_quantity
          click_button 'Volver'
          sleep 1
        end
        click_button 'Dispensar'
        expect(page).to have_content('Viendo receta crónica')
      end
    end # describe dispense

    describe 'End treatment' do
      before(:each) do
        @chronic_prescription_to_et = ChronicPrescription.where(status: 'dispensada_parcial').sample
      end

      it 'button end treatment' do
        visit "recetas/cronicas/#{@chronic_prescription_to_et.id}"
        ocpp = @chronic_prescription_to_et.original_chronic_prescription_products.sample
        expect(page).to have_selector('a.btn-finish-treatment')
        page.first('tr', text: ocpp.product.name).first('a.btn-finish-treatment').click
        sleep 1
        within '#dialog' do
          expect(page).to have_content('Terminar tratamiento')
          expect(page).to have_content('Terminado por el médico')
          expect(page).to have_content('Observaciones')
          expect(page).to have_field('original_chronic_prescription_product[finished_observation]', type: 'textarea')
          expect(page).to have_button('Volver')
          expect(page).to have_button('Aceptar')

          fill_in 'original_chronic_prescription_product[finished_observation]', with: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the.'
          click_button 'Aceptar'
          sleep 1
        end
        expect(page).to have_content("Se ha terminado el tratamiento de #{ocpp.product.name}")
        expect(page).to have_selector('td', text: 'Terminado manual')
      end
    end
  end
end
