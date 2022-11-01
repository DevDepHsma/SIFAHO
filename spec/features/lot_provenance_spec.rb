require 'rails_helper'

RSpec.feature "LotProvenances", type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Procedencia de lotes')
    @read_lots_provenance = permission_module.permissions.find_by(name: 'read_lots_provenance')
    @create_lots_provenance = permission_module.permissions.find_by(name: 'create_lots_provenance')
    @update_lots_provenance = permission_module.permissions.find_by(name: 'update_lots_provenance')
    @destroy_lots_provenance = permission_module.permissions.find_by(name: 'destroy_lots_provenance')
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    it 'Nav Menu link' do
      expect(page.has_css?('#sidebar-wrapper')).to be false
    end

    describe "Add permission:" do
      before(:each) do
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_lots_provenance)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Lotes Provincia')).to be true
          click_link 'Lotes Provincia'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Procedencia')).to be true
        end
        expect(page).to have_content('Procedencias')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_lots_provenance)
        visit current_path
        expect(page).to have_selector('.btn-create')
        page.execute_script %Q{$('a.btn-create').first().click()}
        sleep 1

        expect(page).to have_content('Nueva procedencia')
        expect(page.has_css?('#lot_provenance_name')).to be true
        expect(page.has_button?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true

        within '#new_lot_provenance' do
          page.execute_script %Q{$('#lot_provenance_name').val("SUMAR")}
        end
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('La procedencia se ha creado correctamente.')
        expect(page).to have_content('SUMAR')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @update_lots_provenance)
        visit current_path
        within '#lots_provenance' do
          expect(page).to have_selector('.btn-edit')
          page.execute_script %Q{$('div:contains("SUMAR")').closest('div.border').find('a.btn-edit').click()}
        end
        sleep 1
        expect(page).to have_content('Editar procedencia')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_button?('Guardar')).to be true
        page.execute_script %Q{$('#lot_provenance_name').val("SUMAR T")}
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('La procedencia se ha modificado correctamente.')
        expect(page).to have_content('SUMAR T')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @destroy_lots_provenance)
        visit current_path
        sleep 1
        within '#lots_provenance' do
          expect(page).to have_selector('.delete-item')
          page.execute_script %Q{$('div:contains("SUMAR T")').closest('div.border').find('button.delete-item').click()}
        end
        sleep 1
        expect(page).to have_content('Eliminar procedencia')
        expect(page.has_button?('Volver')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        expect(page).to have_content('La procedencia se ha eliminado correctamente.')
      end
    end
  end
end