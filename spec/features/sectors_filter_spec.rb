require 'rails_helper'

RSpec.feature 'SectorsFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Sectores')
    @read_sectors = permission_module.permissions.find_by(name: 'read_sectors')
    @destroy_sectors = permission_module.permissions.find_by(name: 'destroy_sectors')
    @read_other_establishments = permission_module.permissions.find_by(name: 'read_other_establishments')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_sectors)
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
      visit '/sectores'
    end

    describe 'form filters' do
      it 'has fields' do
        within '#sectors-filter' do
          expect(page).to have_field('filter[name]', type: 'text')
          expect(page).to have_field('filter[establishment_name]', type: 'text')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end

      it 'by name' do
        sectors = Sector.all.sample(5)
        sectors.each do |sector|
          within '#sectors-filter' do
            fill_in 'filter[name]', with: sector.name
            click_button 'Buscar'
            sleep 1
          end
          within '#sectors' do
            expect(page.first('tr').first('td')).to have_selector('mark.highlight-1', text: sector.name)
          end
          within '#sectors-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by establishment_name' do
        sectors = Sector.all.sample(5)
        sectors.each do |sector|
          within '#sectors-filter' do
            fill_in 'filter[establishment_name]', with: sector.establishment.name
            click_button 'Buscar'
            sleep 1
          end
          within '#sectors' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1', text: sector.establishment.name)
          end
          within '#sectors-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Nombre')
          expect(page).to have_button('Establecimiento')
        end
      end

      it 'by name' do
        sorted_by_name_asc = Sector.select(:name).order(name: :asc).first
        sorted_by_name_desc = Sector.select(:name).order(name: :desc).first

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#sectors' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_name_asc.name)
        end

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#sectors' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_name_desc.name)
        end
      end

      it 'by establishment_name' do
        sorted_by_establishment_name_asc = Sector.select(:establishment_id,'establishments.name as establishment_name').joins(:establishment).order(establishment_name: :asc).first
        sorted_by_establishment_name_desc = Sector.select(:establishment_id,'establishments.name as establishment_name').joins(:establishment).order(establishment_name: :desc).first

        within '#table_results' do
          click_button 'Establecimiento'
          sleep 1
        end

        within '#sectors' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_establishment_name_asc.establishment_name)
        end

        within '#table_results' do
          click_button 'Establecimiento'
          sleep 1
        end

        within '#sectors' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_establishment_name_desc.establishment_name)
        end
      end
    end

    describe 'pagination' do
      before(:each) do
        @last_page = (Sector.all.count / 15.to_f).ceil
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
        within '#sectors' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#sectors' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Destroy permission' do
      before(:each) do
        @sector_to_del = Sector.create(name:'sector test',description:'test new in sector for destruction',establishment_id:@farm_applicant.active_sector.establishment.id)
        within '#sectors-filter' do
          fill_in 'filter[name]', with: @sector_to_del.name
          click_button 'Buscar'
          sleep 1
        end
      end

      after(:each) do
        @sector_to_del.delete
      end

      it 'has button destroy' do
        within '#sectors' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#sectors' do
          page.all('button.delete-item').first.click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar sector')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy items' do
        within '#sectors' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        # expect(page).to have_text("El suministro #{@product_to_del.name} se ha eliminado correctamente.")
      end
    end
  end
end
