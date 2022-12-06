require 'rails_helper'

RSpec.feature 'EstablishmentsFilters', type: :feature do
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
      visit '/establecimientos'
    end

    describe 'form filters' do
      it 'has fields' do
        within '#establishments-filter' do
          # expect(page).to have_field('filter[cuie]', type: 'text')
          expect(page).to have_field('filter[name]', type: 'text')
          expect(page).to have_select('filter[establishment_type]')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end
      # ###############Se deja comentado porque ya no se utiliza el cuie y se encuentra oculto###################
      # it 'by cuie' do
      #   establishments = Establishment.all.sample(5)
      #   establishments.each do |establishment|
      #     within '#establishments-filter' do
      #       fill_in 'filter[cuie]', with: establishment.cuie
      #       click_button 'Buscar'
      #       sleep 1
      #     end
      #     within '#establishments' do
      #       expect(page.first('tr').first('td')).to have_selector('mark.highlight-1', text: establishment.cuie)
      #     end
      #     within '#establishments-filter' do
      #       page.first('button.btn-clean-filters').click
      #       sleep 1
      #     end
      #   end
      # end

      it 'by name' do
        establishments = Establishment.all.sample(5)
        establishments.each do |establishment|
          within '#establishments-filter' do
            fill_in 'filter[name]', with: establishment.name
            click_button 'Buscar'
            sleep 1
          end
          within '#establishments' do
            expect(page.first('tr').find('td:nth-child(1)')).to have_selector('mark.highlight-1',
                                                                              text: establishment.name)
          end
          within '#establishments-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'for type' do
        establishment_type = EstablishmentType.all.sample(3)
        establishment_type.each do |type|
          within '#establishments-filter' do
            select type.name, from: 'filter[establishment_type]'
            click_button 'Buscar'
            sleep 1
          end
          within '#establishments' do
            expect(page.first('tr').all('td')[1]).to have_content(type.name)
          end
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          # expect(page).to have_button('CUIE')
          expect(page).to have_button('Nombre')
          expect(page).to have_button('Tipo')
          expect(page).to have_button('Sectores')
          expect(page).to have_button('Usuarios')
        end
      end
      # ##################Cuie se encuentra oculto ################################
      # it 'by cuie' do
      #   sorted_by_cuie_asc = Establishment.select(:cuie).order(cuie: :asc).first
      #   sorted_by_cuie_desc = Establishment.select(:cuie).order(cuie: :desc).first

      #   within '#table_results' do
      #     click_button 'CUIE'
      #     sleep 1
      #   end

      #   within '#establishments' do
      #     expect(page.first('tr').first('td')).to have_content(sorted_by_cuie_asc.cuie)
      #   end

      #   within '#table_results' do
      #     click_button 'CUIE'
      #     sleep 1
      #   end

      #   within '#establishments' do
      #     expect(page.first('tr').first('td')).to have_content(sorted_by_cuie_desc.cuie)
      #   end
      # end

      it 'by name' do
        sorted_by_name_asc = Establishment.select(:name).order(name: :asc).first
        sorted_by_name_desc = Establishment.select(:name).order(name: :desc).first

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#establishments' do
          expect(page.first('tr').find('td:nth-child(1)')).to have_text(sorted_by_name_asc.name)
        end

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#establishments' do
          expect(page.first('tr').find('td:nth-child(1)')).to have_text(sorted_by_name_desc.name)
        end
      end

      it 'by type' do
        sorted_by_type_asc = Establishment.select('establishment_types.name').joins(:establishment_type).order('establishment_types.name asc').first
        sorted_by_type_desc = Establishment.select('establishment_types.name').joins(:establishment_type).order('establishment_types.name desc').first
        within '#table_results' do
          click_button 'Tipo'
          sleep 1
        end

        within '#establishments' do
          expect(page.first('tr').all('td')[1]).to have_text(sorted_by_type_asc.name)
        end

        within '#table_results' do
          click_button 'Tipo'
          sleep 1
        end

        within '#establishments' do
          expect(page.first('tr').all('td')[1]).to have_text(sorted_by_type_desc.name)
        end
      end
    end

    # ####################No hay suficientes establecimientos como para la paginación################

    # describe 'pagination' do
    #   before(:each) do
    #     @last_page = (Establishment.all.count / 15.to_f).ceil
    #   end

    #   it 'has pagination' do
    #     within '#paginate_footer nav' do
    #       expect(page).to have_selector('a.page-link', text: @last_page.to_s)
    #     end
    #   end

    #   it 'has pagination size selector' do
    #     within '#paginate_footer' do
    #       expect(page).to have_select('page-size-selection', with_options: %w[15 30 50 100])
    #     end
    #   end

    #   it 'change page number' do
    #     within '#paginate_footer nav' do
    #       expect(page).to have_selector('li.active', text: '1')
    #       click_link @last_page.to_s
    #       sleep 1
    #       expect(page).to have_selector('li.active', text: @last_page.to_s)
    #     end
    #   end

    #   it 'has 15 items per page by default' do
    #     within '#establishments' do
    #       expect(page).to have_selector('tr', count: 15)
    #     end
    #   end

    #   it 'change items per page to 30' do
    #     within '#paginate_footer' do
    #       page.select '30', from: 'page-size-selection'
    #       sleep 1
    #     end
    #     within '#establishments' do
    #       expect(page).to have_selector('tr', count: 30)
    #     end
    #   end
    # end

    describe 'Destroy permission' do
      before(:each) do
        @establishment_to_del = Establishment.create(name: 'establishment test',
                                                     short_name: 'et', establishment_type_id: 3, sanitary_zone_id: 3)
        within '#establishments-filter' do
          fill_in 'filter[name]', with: @establishment_to_del.name
          click_button 'Buscar'
          sleep 1
        end
      end

      after(:each) do
        @establishment_to_del.delete
      end

      it 'has button destroy' do
        within '#establishments' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#establishments' do
          page.all('button.delete-item').first.click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar establecimiento')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy items' do
        within '#establishments' do
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
