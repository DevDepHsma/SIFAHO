require 'rails_helper'

RSpec.feature "Stocks", type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Stock')
    @read_stocks = permission_module.permissions.find_by(name: 'read_stocks')
    @read_archive_stocks = permission_module.permissions.find_by(name: 'read_archive_stocks')
    @create_archive_stocks = permission_module.permissions.find_by(name: 'create_archive_stocks')
    @return_archive_stocks = permission_module.permissions.find_by(name: 'return_archive_stocks')
    @read_lot_stocks = permission_module.permissions.find_by(name: 'read_lot_stocks')
    @read_movement_stocks = permission_module.permissions.find_by(name: 'read_movement_stocks')

    pm_lots = PermissionModule.includes(:permissions).find_by(name: 'Lotes')
    @read_lots = pm_lots.permissions.find_by(name: 'read_lots')
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
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_stocks)
        visit '/'
      end

      it 'Nav Menu link' do
        expect(page.has_css?('#sidebar-wrapper', visible: false)).to be true
        within '#sidebar-wrapper' do
          expect(page.has_link?('Stock')).to be true
          click_link 'Stock'
        end
        within '#dropdown-menu-header' do
          expect(page.has_link?('Stock')).to be true
        end
        expect(page).to have_selector('#stocks')

        within '#stocks' do
          expect(page).to have_selector('.btn-detail')
          page.execute_script %Q{$('a.btn-detail')[0].click()}
        end

        expect(page).to have_content('Viendo stock de')
        expect(page).not_to have_selector('#lots-tab')
        expect(page).not_to have_selector('#movements-tab')
        expect(page).not_to have_selector('#statistics-tab')
        expect(page).not_to have_selector('#lot-archives')
        expect(page.has_link?('Volver')).to be true
        expect(page.has_link?('Imprimir')).to be true
        expect(page.has_link?('Ver Lotes')).to be false
        expect(page.has_link?('Ver Movimientos')).to be false
        expect(page).not_to have_selector('.btn-detail-lot')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_lot_stocks)
        visit current_path
        expect(page).to have_selector('#lots-tab')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_lots)
        visit current_path
        expect(page).to have_selector('.btn-detail-lot')

        # ======= Lot detail ==========
        within '#page-content-wrapper' do
          click_link 'Lotes'
        end
        page.execute_script %Q{$('a.btn-detail-lot')[0].click()}
        expect(page).to have_content('Viendo lote')
        expect(page).to have_content('Reservado')
        expect(page).not_to have_content('Archivos')
        expect(page.has_link?('Volver')).to be true
        # Archived
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_archive_stocks)
        visit current_path
        expect(page).to have_content('Archivos')
        expect(page).to have_selector('#lot-archives', visible: false)
        # Lot stock Movements
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @read_movement_stocks)
        visit current_path
        expect(page).to have_content('Últimos movimientos')
        expect(page).to have_selector('#movements-tab')
        click_link 'Volver'

        # ======= Lot stocks list =========
        expect(page).to have_content('Últimos movimientos')
        expect(page).not_to have_selector('.btn-archive')
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @create_archive_stocks)
        visit current_path
        expect(page).to have_selector('.btn-archive')
        page.execute_script %Q{$('a.btn-archive')[0].click()}
        sleep 1
        expect(page).to have_selector('#lot_archive_quantity')
        expect(page).to have_selector('#lot_archive_observation')
        expect(page).to have_content('Archivando lote')
        within '#new_lot_archive' do
          fill_in 'lot_archive_quantity', with: 10
          fill_in 'lot_archive_observation', with: 'Archive test'
        end
        expect(page.has_button?('Volver')).to be true
        expect(page.has_button?('Archivar')).to be true
        click_button 'Archivar'
        expect(page).to have_content('Viendo archivo de lote')
        within '#dropdown-menu-header' do
          click_link 'Stock'
        end
        sleep 1
        page.execute_script %Q{$('a.btn-detail')[0].click()}
        sleep 1
        page.execute_script %Q{$('a.btn-detail-lot')[0].click()}
        expect(page).to have_content('Archivos')
        click_link 'Archivos'
        expect(page).to have_selector('#lot-archives')
        within '#lot-archives' do
          expect(page).to have_selector('.btn-detail-archive')
          expect(page).not_to have_selector('.btn-return-archive')
        end
        PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.sector, permission: @return_archive_stocks)
        visit current_path
        click_link 'Archivos'
        expect(page).to have_selector('#lot-archives')
        within '#lot-archives' do
          expect(page).to have_selector('.btn-detail-archive')
          expect(page).to have_selector('.btn-return-archive')
          page.execute_script %Q{$('a.btn-return-archive')[0].click()}
          sleep 1
        end
        expect(page).to have_content('Se retornarán 10 unidades al stock')
        expect(page).to have_content('Esta seguro de retornar este archivo?')
        expect(page.has_button?('Cancelar')).to be true
        expect(page.has_link?('Confirmar')).to be true
        click_link 'Confirmar'
        sleep 1
        click_link 'Archivos'
        within '#lot-archives' do
          expect(page).not_to have_selector('.btn-return-archive')
        end
      end
    end
  end
end