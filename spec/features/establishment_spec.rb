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
    describe 'Permission'

    it 'List' do
      visit '/'
      expect(page).to have_css('#sidebar-wrapper', visible: false)
      within '#sidebar-wrapper' do
        expect(page).to have_link('Establecimientos')
        click_link 'Establecimientos'
      end
      within '#dropdown-menu-header' do
        expect(page).to have_link('Establecimientos')
      end
    end

    it 'Show' do
      visit '/establecimientos'
      within '#establishments' do
        expect(page).to have_css('.btn-detail')
      end
      establishment = Establishment.all.sample
      visit "/establecimientos/#{establishment.id}"
      expect(page).to have_content('Viendo establecimiento')
      expect(page).to have_content('Información')
      expect(page).to have_content('Ubicación')
      expect(page).to have_content('Sectores')
      expect(page).to have_content('Usuarios')
      expect(page).to have_link('Volver')
    end

    it 'Send:fail' do
      visit '/establecimientos'
      within '#dropdown-menu-header' do
        expect(page).to have_link('Agregar')
        click_link 'Agregar'
      end
      expect(page).to have_link('Volver')
      expect(page).to have_button('Guardar')
      click_button 'Guardar'
      sleep 1
      expect(page).to have_content('Nombre no puede estar en blanco')
      expect(page).to have_content('Nombre abreviado no puede estar en blanco')
      expect(page).to have_content('Zona sanitaria no puede estar en blanco')
      expect(page).to have_content('Tipo de establecimiento no puede estar en blanco')
    end
    it 'Create: form and fields' do
      visit '/establecimientos'
      within '#dropdown-menu-header' do
        expect(page).to have_link('Agregar')
        click_link 'Agregar'
      end
      within '#new_establishment' do
        expect(page).to have_selector('#establishment_name')
        expect(page).to have_selector('#establishment_short_name')
        expect(page).to have_selector('#sanitary_zone', visible: false)
        expect(page).to have_selector('#establishment_type', visible: false)
        fill_in 'establishment_name', with: 'Hospital Villa La Angostura'
        fill_in 'establishment_short_name', with: 'HVLA'
        click_button 'Seleccionar zona sanitaria'
        find('button', text: 'Seleccionar zona sanitaria').sibling('div', class: 'dropdown-menu').first('a',
                                                                                                        text: 'Zona Sanitaria IV').click
        click_button 'Seleccionar tipo'
        find('button', text: 'Seleccionar tipo').sibling('div', class: 'dropdown-menu').first('a',
                                                                                              text: 'Hospital').click
      end
      expect(page).to have_link('Volver')
      expect(page).to have_button('Guardar')
      click_button 'Guardar'
      expect(page).to have_content('Viendo establecimiento')
    end

    it 'Edit: form and fields' do
      visit '/establecimientos'
      within '#establishments' do
        expect(page).to have_css('.btn-edit')
      end
      establishment = Establishment.all.sample

      visit "/establecimientos/#{establishment.id}/editar"
      sleep 1
      within "#edit_establishment_#{establishment.id}" do
        expect(page).to have_selector('#establishment_name')
        expect(page).to have_selector('#establishment_short_name')
        expect(page).to have_selector('#sanitary_zone', visible: false)
        expect(page).to have_selector('#establishment_type', visible: false)
        fill_in 'establishment_name', with: 'Hospital Villa La Angostura'
        fill_in 'establishment_short_name', with: 'HVLA'
        find("button[data-id='sanitary_zone']").click
        find("button[data-id='sanitary_zone']").sibling('div', class: 'dropdown-menu').first('a',
                                                                                             text: 'Zona Sanitaria IV').click
        find("button[data-id='establishment_type']").click
        find("button[data-id='establishment_type']").sibling('div', class: 'dropdown-menu').first('a',
                                                                                                  text: 'Hospital').click
      end
      expect(page).to have_link('Volver')
      expect(page).to have_button('Guardar')
      click_button 'Guardar'
      expect(page).to have_content('Viendo establecimiento')
    end
  end
end
