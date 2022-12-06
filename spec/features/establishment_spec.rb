require 'rails_helper'

RSpec.feature 'Establishments', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Establecimientos')
    @read_establishments = permission_module.permissions.find_by(name: 'read_establishments')
    @create_establishments = permission_module.permissions.find_by(name: 'create_establishments')
    @update_establishments = permission_module.permissions.find_by(name: 'update_establishments')
    @destroy_establishments = permission_module.permissions.find_by(name: 'destroy_establishments')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_establishments)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @create_establishments)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @update_establishments)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @destroy_establishments)
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
          expect(page).to have_link('Establecimientos')
          click_link 'Establecimientos'
        end
        within '#dropdown-menu-header' do
          expect(page).to have_link('Establecimientos')
        end
      end

      describe 'actions' do
        before(:each) do
          visit '/establecimientos'
          sleep 1
        end
        it 'create' do
          within '#dropdown-menu-header' do
            expect(page).to have_link('Agregar')
            click_link 'Agregar'
          end
          expect(page).to have_selector('#establishment_name')
          expect(page).to have_selector('#establishment_short_name')
          expect(page).to have_selector('#sanitary_zone', visible: false)
          expect(page).to have_selector('#establishment_type', visible: false)
          expect(page).to have_content('Agregar establecimiento')
        end
        it 'list' do
          expect(page).to have_selector('#establishments')
          within '#establishments' do
            expect(page).to have_selector('tr')
            expect(page).to have_selector('.btn-detail')
            expect(page).to have_selector('.btn-edit')
            expect(page).to have_selector('.delete-item')
          end
        end
        it 'show' do
          establishment = Establishment.all.sample
          expect(page).to have_selector('#establishments')
          visit "/establecimientos/#{establishment.id}"
          expect(page).to have_content("Viendo establecimiento #{establishment.name}")
          expect(page).to have_content('CUIE')
          expect(page).to have_content('Email')
          expect(page).to have_content('Teléfono')
          expect(page).to have_content('Domicilio')
          expect(page).to have_content('Cuit')
          expect(page).to have_content('SISA')
        end

        it 'edit' do
          within '#establishments' do
            page.all('a.btn-edit').first.click
          end
          expect(page).to have_content('Editando establecimiento')
          expect(page).to have_link('Volver')
          expect(page).to have_button('Guardar')
        end
      end
    end

    describe 'actions' do
      before(:each) do
        visit '/establecimientos'
      end
      it 'edit' do
        within '#establishments' do
          page.all('a.btn-edit').first.click
        end
        fill_in 'establishment[name]',	with: 'sometext'
        fill_in 'establishment[short_name]',
                with: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Neque, odio!'
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('Viendo establecimiento sometext')
      end

      it 'create' do
        sanitary_zone = SanitaryZone.all.sample
        type_establishment = EstablishmentType.all.sample
        click_link 'Agregar'
        sleep 1
        click_button 'Guardar'
        sleep 1
        expect(page).to have_content('Por favor revise los campos en el formulario:')
        expect(page).to have_content('Nombre no puede estar en blanco')
        expect(page).to have_content('Nombre abreviado no puede estar en blanco')
        expect(page).to have_content('Zona sanitaria no puede estar en blanco')
        expect(page).to have_content('Tipo de establecimiento no puede estar en blanco')
        within '#new_establishment' do
          fill_in 'establishment[name]', with: 'Cocina'
          fill_in 'establishment[short_name]',
                  with: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Neque, odio!'
          page.find("button[title='Seleccionar zona sanitaria']").click
          sleep 1
          page.find('a', text: sanitary_zone.name).click
          page.find("button[title='Seleccionar tipo']").click
          sleep 1
          page.find('a', text: type_establishment.name).click
        end
        click_button 'Guardar'
        expect(page).to have_content('Viendo establecimiento Cocina')
      end
    end
  end
end
