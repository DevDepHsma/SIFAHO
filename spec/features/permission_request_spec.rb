require 'rails_helper'

RSpec.feature 'PermissionRequests', type: :feature, js: true do
  before(:all) do
    @user_requested = create(:user_1)
    @user_active_without_sector = create(:user, username: '25654789')
  end

  describe 'Permission Requests' do
    background do
      sign_in @user_requested
    end

    subject { page }

    before(:each) do
      visit '/'
    end
    after(:each) do
      pr = PermissionRequest.find_by(user_id: @user_requested.id)
      pr.destroy if pr.present?
    end

    describe 'Form' do
      it 'has fields' do
        roles = Role.all
        within '#page-content-wrapper' do
          expect(page).to have_content('Solicitud de permisos')
          expect(page).to have_content('Complete el formulario para comenzar a utilizar el sistema.')
          expect(page).to have_selector('label', text: '¿A cuál establecimiento pertenece? *')
          expect(page).to have_field('permission_request[establishment_id]', visible: false)
          expect(page).to have_content('¿Qué funciones requiere?')
          roles.each do |role|
            expect(page).to have_field(role.name, type: 'checkbox', visible: false)
          end
          expect(page).to have_selector('label', text: 'Observaciones')
          expect(page).to have_field('permission_request[observation]', type: 'textarea')
          expect(page).to have_content('Una vez enviado, deberá esperar a que algún gestor de usuarios responda la solicitud.')
          expect(page).to have_button('Enviar')
        end
      end

      it 'show sector select on establishment selected' do
        establishment = Establishment.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: establishment.name).click

          expect(page).to have_selector('label', text: '¿A cuál sector pertenece?')
          expect(page).to have_select('permission_request[sector_id]', visible: false)
        end
      end

      it 'successfully save with establishment and sector' do
        establishment = Establishment.all.sample
        role = Role.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: establishment.name).click

          element = page.find('select#permission_request_sector_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: establishment.sectors.sample.name).click

          page.first('label', text: role.name).click
          fill_in 'permission_request_observation',
                  with: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
        end
        click_button 'Enviar'
        expect(page).to have_content('Solicitud enviada.')
        expect(page).to have_content('Espere una respuesta')
        expect(page).to have_content('El equipo de gestión evaluará su solicitud y tomará las medidas correspondientes.')
      end

      it 'show other sector input on sector select "otro.." option' do
        establishment = Establishment.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: establishment.name).click
          element = page.find('select#permission_request_sector_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: 'Otro...').click

          expect(page).to have_selector('label', text: 'Especifique el sector')
          expect(page).to have_field('permission_request[other_sector]', type: 'text')
        end
      end

      it 'successfully save with establishment and other sector' do
        establishment = Establishment.all.sample
        role = Role.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: establishment.name).click

          element = page.find('select#permission_request_sector_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: 'Otro...').click

          fill_in 'permission_request[other_sector]', with: 'New sector'
          page.first('label', text: role.name).click
          fill_in 'permission_request_observation',
                  with: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
        end
        click_button 'Enviar'
        expect(page).to have_content('Solicitud enviada.')
        expect(page).to have_content('Espere una respuesta')
        expect(page).to have_content('El equipo de gestión evaluará su solicitud y tomará las medidas correspondientes.')
      end

      it 'show other sector input and other establishment input on establishment select "otro.." option ' do
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: 'Otro...').click

          expect(page).to have_selector('label', text: 'Especifique el establecimiento')
          expect(page).to have_field('permission_request[other_establishment]', type: 'text')
          expect(page).to have_selector('label', text: 'Especifique el sector')
          expect(page).to have_field('permission_request[other_sector]', type: 'text')
        end
      end

      it 'successfully save with other establishment' do
        role = Role.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: 'Otro...').click

          fill_in 'permission_request[other_establishment]', with: 'New establishment'
          fill_in 'permission_request[other_sector]', with: 'New sector'
          page.first('label', text: role.name).click
          fill_in 'permission_request_observation',
                  with: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.'
        end
        click_button 'Enviar'
        expect(page).to have_content('Solicitud enviada.')
        expect(page).to have_content('Espere una respuesta')
        expect(page).to have_content('El equipo de gestión evaluará su solicitud y tomará las medidas correspondientes.')
      end
    end

    describe 'Form validations' do
      it 'Establishment and roles required' do
        click_button 'Enviar'
        within '#new_permission_request' do
          expect(page).to have_content('Establecimiento no puede estar en blanco')
          expect(page).to have_content('Debe seleccionar una función')
        end
      end

      it 'Sector is required' do
        establishment = Establishment.all.sample
        role = Role.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: establishment.name).click
          page.first('label', text: role.name).click
        end
        click_button 'Enviar'
        within '#new_permission_request' do
          expect(page).to have_content('Sector no puede estar en blanco')
        end
      end

      it 'Other establishment and Other sector are required' do
        role = Role.all.sample
        within '#new_permission_request' do
          element = page.find('select#permission_request_establishment_id', visible: false)
          element.sibling('button', class: 'dropdown-toggle').click
          page.find('li', text: 'Otro..').click
          page.first('label', text: role.name).click
        end
        click_button 'Enviar'
        within '#new_permission_request' do
          expect(page).to have_content('Establecimiento no puede estar en blanco')
          expect(page).to have_content('Sector no puede estar en blanco')
        end
      end
    end
  end
end
