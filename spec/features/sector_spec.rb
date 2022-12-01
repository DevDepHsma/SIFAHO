require 'rails_helper'

RSpec.feature 'Sectors', type: :feature do
  require 'rails_helper'

  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Sectores')
    @read_sectors = permission_module.permissions.find_by(name: 'read_sectors')
    @create_sectors = permission_module.permissions.find_by(name: 'create_sectors')
    @update_sectors = permission_module.permissions.find_by(name: 'update_sectors')
    @destroy_sectors = permission_module.permissions.find_by(name: 'destroy_sectors')
    @select_establishment = permission_module.permissions.find_by(name: 'create_to_other_establishment')
    @read_other_establishments = permission_module.permissions.find_by(name: 'read_other_establishments')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_sectors)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @create_sectors)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @select_establishment)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @update_sectors)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_other_establishments)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @destroy_sectors)
  end

  background do
    sign_in @farm_applicant
  end
  describe '', js: true do
    subject { page }

    before(:each) do
      visit '/'
    end

    describe 'access permissions' do
      it 'Nav Menu link' do
        expect(page).to have_selector('#sidebar-wrapper', visible: false)
        within '#sidebar-wrapper' do
          expect(page).to have_link('Sectores')
          click_link 'Sectores'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Sectores')
        end
      end
      
      describe 'actions' do
        before(:each) do
          visit '/sectores'
        end
        it 'create' do
          within '#dropdown-menu-header' do
            expect(page).to have_link('Crear sector')
            click_link 'Crear sector'
          end
          expect(page).to have_selector('#sector_name')
          expect(page).to have_selector('#sector_description')
          expect(page).to have_content(@farm_applicant.active_sector.establishment.name)
          expect(page).to have_selector('#sector_establishment_id', visible: false)
        end
        it 'list' do
          expect(page).to have_selector('#sectors')
          within '#sectors' do
            expect(page).to have_selector('tr')
            expect(page).to have_selector('.btn-detail')
            expect(page).to have_selector('.btn-edit')
            expect(page).to have_selector('.delete-item')
          end
        end
        it 'show' do
          sector = Sector.all.sample
          expect(page).to have_selector('#sectors')
          visit "/sectores/#{sector.id}"
          expect(page).to have_content("Viendo sector #{sector.name}")
          expect(page).to have_content("Establecimiento: #{sector.establishment.name}")
          expect(page).to have_content("Descripción: #{sector.description}")
          if sector.provide_hospitalization
            expect(page).to have_content('Internación: Si')
          else
            expect(page).to have_content('Internación: No')
          end
        end

        it 'edit' do
          within '#sectors' do
            page.all('a.btn-edit').first.click
          end
          expect(page).to have_content('Editando sector')
          expect(page).to have_link('Volver')
          expect(page).to have_button('Guardar')
        end
      end
    end

    describe 'actions' do
      before(:each) do
        visit '/sectores'
      end
      it 'edit' do
        within '#sectors' do
          page.all('a.btn-edit').first.click
        end
        fill_in 'Nombre',	with: 'sometext'
        fill_in 'Descripción',	with: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Neque, odio!'
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('Viendo sector sometext')
      end

      it 'create' do
       click_link 'Crear sector'
        within '#new_sector' do
          fill_in 'Nombre', with: 'Cocina'
          fill_in 'Descripción', with: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Neque, odio!'
        end
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('Viendo sector Cocina')
      end

      it 'delete' do
        within '#sectors' do
          expect(page).to have_selector('.delete-item')
          page.all('tr', text: 'Cocina').first.find('button.delete-item').click
        end
        sleep 1
        expect(page).to have_content('Eliminar sector')
        expect(page).to have_button('Volver')
        expect(page).to have_link('Confirmar')
        expect(page).to have_content('Esta seguro que desea eliminar el sector Cocina?')
        click_link 'Confirmar'
        sleep 1
        expect(page).to have_content('El sector Cocina se ha eliminado correctamente.')
      end
    end
  end
end
