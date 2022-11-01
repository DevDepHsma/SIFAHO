# == Test Information

#  Testing modules:
#  Filter: fields and results
#  Pagination: presence and results
#  Sort: buttons and results
#  Destroy action
#  Return action
#

require 'rails_helper'

RSpec.feature 'OutpatientsPrescriptionsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Recetas Ambulatorias')
    @read_outpatient_permission = permission_module.permissions.find_by(name: 'read_outpatient_recipes')
    @return_recipe_permission = permission_module.permissions.find_by(name: 'return_outpatient_recipes')
    @destroy_recipe_permission = permission_module.permissions.find_by(name: 'destroy_outpatient_recipes')
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @return_recipe_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @read_outpatient_permission)
    PermissionUser.create(user: @farm_provider, sector: @farm_provider.sector,
                          permission: @destroy_recipe_permission)
    @outpatients = OutpatientPrescription.all.sample(5)
  end

  background do
    sign_in @farm_provider
  end

  describe 'Outpatient Recipes ::', js: true do
    subject { page }

    before(:each) do
      visit '/recetas/ambulatorias'
      @op_prescriptions = OutpatientPrescription.all.sample(5)
    end

    describe 'form filter' do
      it 'has fields' do
        within '#outpatient-prescriptions-filter' do
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
        @op_prescriptions.each do |opp|
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[code]', with: opp.remit_code
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').first('td')).to have_selector('mark.highlight', text: opp.remit_code)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by professional fullname' do
        @op_prescriptions.each do |opp|
          # By first name
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[professional_full_name]', with: opp.professional.first_name
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1',
                                                                              text: opp.professional.first_name)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
          # By last name
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[professional_full_name]', with: opp.professional.last_name
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1',
                                                                              text: opp.professional.last_name)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by patient full_name' do
        @op_prescriptions.each do |opp|
          within '#outpatient-prescriptions-filter' do
            # By dni
            fill_in 'filter[patient_full_name]', with: opp.patient.dni
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_content(opp.patient.dni)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
          # By first name
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[patient_full_name]', with: opp.patient.first_name
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_selector('mark.highlight-2',
                                                                              text: opp.patient.first_name)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
          # By last name
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[patient_full_name]', with: opp.patient.last_name
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_selector('mark.highlight-2',
                                                                              text: opp.patient.last_name)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by date_prescribed_since and date_prescribed_to' do
        @op_prescriptions.each do |opp|
          within '#outpatient-prescriptions-filter' do
            fill_in 'filter[date_prescribed_since]', with: opp.date_prescribed.strftime('%d/%m/%Y')
            fill_in 'filter[date_prescribed_to]', with: opp.date_prescribed.strftime('%d/%m/%Y')
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(6)')).to have_content(opp.date_prescribed.strftime('%d/%m/%Y'))
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by status' do
        @op_prescriptions.each do |opp|
          within '#outpatient-prescriptions-filter' do
            page.select opp.status, from: 'filter[status]'
            click_button 'Buscar'
            sleep 1
          end
          within '#outpatient_prescriptions' do
            expect(page.first('tr').find('td:nth-child(4)')).to have_content(opp.status.underscore.humanize)
          end
          within '#outpatient-prescriptions-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end

    describe 'pagination' do
      before(:each) do
        @last_page = (OutpatientPrescription.all.count / 15.to_f).ceil
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
        within '#outpatient_prescriptions' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#outpatient_prescriptions' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Médico')
          expect(page).to have_button('Paciente')
          expect(page).to have_button('Recetada')
        end
      end

      it 'by professional' do
        sorted_by_professional_asc = OutpatientPrescription.select('professionals.fullname AS pr_fullname').joins(:professional).order('pr_fullname asc').first
        sorted_by_professional_desc = OutpatientPrescription.select('professionals.fullname AS pr_fullname').joins(:professional).order('pr_fullname desc').first

        within '#table_results' do
          click_button 'Médico'
          sleep 1
        end

        within '#outpatient_prescriptions' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_content(sorted_by_professional_asc.pr_fullname)
        end

        within '#table_results' do
          click_button 'Médico'
          sleep 1
        end

        within '#outpatient_prescriptions' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_content(sorted_by_professional_desc.pr_fullname)
        end
      end

      it 'by name' do
        sorted_by_patient_asc = OutpatientPrescription.select('patients.first_name AS pa_first_name',
                                                              'patients.last_name AS pa_last_name', 'patients.dni AS pa_dni').joins(:patient).order('pa_last_name asc').first
        sorted_by_patient_desc = OutpatientPrescription.select('patients.first_name AS pa_first_name',
                                                               'patients.last_name AS pa_last_name', 'patients.dni AS pa_dni').joins(:patient).order('pa_last_name desc').first

        within '#table_results' do
          click_button 'Paciente'
          sleep 1
        end

        within '#outpatient_prescriptions' do
          expect(page.first('tr').find('td:nth-child(3)')).to have_text(sorted_by_patient_asc.pa_last_name)
        end

        within '#table_results' do
          click_button 'Paciente'
          sleep 1
        end

        within '#outpatient_prescriptions' do
          expect(page.first('tr').find('td:nth-child(3)')).to have_text(sorted_by_patient_desc.pa_last_name)
        end
      end

      it 'by date prescribed' do
        sorted_by_date_prescribed_asc = OutpatientPrescription.select(:date_prescribed).order('date_prescribed asc').first
        sorted_by_date_prescribed_desc = OutpatientPrescription.select(:date_prescribed).order('date_prescribed desc').first

        within '#table_results' do
          click_button 'Recetada'
          sleep 1
        end

        within '#outpatient_prescriptions' do
          expect(page.first('tr').find('td:nth-child(6)')).to have_text(sorted_by_date_prescribed_asc.date_prescribed.strftime('%d/%m/%Y'))
        end

        within '#table_results' do
          click_button 'Recetada'
          sleep 1
        end

        within '#outpatient_prescriptions' do
          expect(page.first('tr').find('td:nth-child(6)')).to have_text(sorted_by_date_prescribed_desc.date_prescribed.strftime('%d/%m/%Y'))
        end
      end
    end

    describe 'Destroy permission' do
      before(:each) do
        @outpatient_prescription_to_del = OutpatientPrescription.where(status: 'pendiente').sample
        within '#outpatient-prescriptions-filter' do
          fill_in 'filter[code]', with: @outpatient_prescription_to_del.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button destroy' do
        within '#outpatient_prescriptions' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#outpatient_prescriptions' do
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
        within '#outpatient_prescriptions' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text("La receta de #{@outpatient_prescription_to_del.professional.fullname} se ha eliminado correctamente.")
      end
    end

    describe 'Return permission' do
      before(:each) do
        @outpatient_prescription_to_return = OutpatientPrescription.where(status: 'dispensada').sample
        within '#outpatient-prescriptions-filter' do
          fill_in 'filter[code]', with: @outpatient_prescription_to_return.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button show' do
        within '#outpatient_prescriptions' do
          expect(page).to have_selector('a.btn-detail')
        end
      end

      it 'redirect to shown view' do
        within '#outpatient_prescriptions' do
          page.first('a.btn-detail').click
        end
        expect(page).to have_content('Viendo receta ambulatoria')
        expect(page).to have_link('Volver')
        expect(page).to have_button('Retornar')
        expect(page).to have_link('Imprimir')

        click_button 'Retornar'
        sleep 1
        within '#return-confirm' do
          expect(page).to have_content('Retornar a Pendiente')
          expect(page).to have_link('Cancelar')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'return prescription' do
        visit "/recetas/ambulatorias/#{@outpatient_prescription_to_return.id}"
        click_button 'Retornar'
        sleep 1
        within '#return-confirm' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text('La receta se ha retornado a pendiente.')
      end
    end
  end
end
