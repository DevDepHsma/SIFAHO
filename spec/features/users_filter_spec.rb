require 'rails_helper'

RSpec.feature 'UsersFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Usuarios')
    @read_users = permission_module.permissions.find_by(name: 'read_users')
    @answer_permission_request = permission_module.permissions.find_by(name: 'answer_permission_request')
    @update_permissions = permission_module.permissions.find_by(name: 'update_permissions')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @read_users)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @answer_permission_request)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector, permission: @update_permissions)

    @user_permission_requested = @users_permission_requested.sample
    @permission_request = PermissionRequest.where(user_id: @user_permission_requested.id).first
  end

  background do
    sign_in @farm_applicant
  end

  describe '', js: true do
    subject { page }

    before(:each) do
      visit '/usuarios'
    end

    describe 'form filters' do
      it 'has fields' do
        within '#users-filter' do
          expect(page).to have_field('filter[username]', type: 'text')
          expect(page).to have_field('filter[fullname]', type: 'text')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end

      it 'by dni' do
        users = User.where(status: 1).sample(5)
        users.each do |user|
          within '#users-filter' do
            fill_in 'filter[username]', with: user.username
            click_button 'Buscar'
            sleep 1
          end

          within '#users' do
            expect(page.find('tr:first-child td:nth-child(2) mark.highlight-1')).to have_content(user.username)
          end
          within '#users-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by name' do
        users = User.where(status: 1).sample(5)
        users.each do |user|
          within '#users-filter' do
            fill_in 'filter[fullname]', with: user.profile.first_name
            click_button 'Buscar'
            sleep 1
          end
          within '#users' do
            expect(page.first('tr').find('td:nth-child(4)')).to have_selector('mark.highlight-1',
                                                                              text: user.profile.first_name)
          end
          within '#users-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by establishment' do
        users = User.where(status: 1).sample(5)
        users.each do |user|
          establishment = user.active_sector.establishment
          sector = user.active_sector
          within '#users-filter' do
            page.find('button[data-id="filter_establishment"]').click
            sleep 1
            input_establishment = page.all('.bs-searchbox input').first
            input_establishment.fill_in with: establishment.name
            page.first('.inner.show ul li a').click
            page.find('button[data-id="filter_sector"]').click
            sleep 1
            input_establishment = page.all('.bs-searchbox input').first
            input_establishment.fill_in with: sector.name
            page.first('.inner.show ul li a').click
            click_button 'Buscar'
            sleep 1
          end
          within '#users' do
            expect(page.first('tr').find('td:nth-child(4)')).to have_content(user.first_name)
          end
          within '#users-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end

    describe 'pagination' do
      before(:each) do
        visit '/usuarios'
        @last_page = (User.where(status: 1).count / 15.to_f).ceil
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
        within '#users' do
          expect(page).to have_selector('tr', count: 15, visible: false)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#users' do
          expect(page).to have_selector('tr', count: 30, visible: false)
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Usuario')
          expect(page).to have_button('Apellido')
          expect(page).to have_button('Nombre')
        end
      end

      it 'by code' do
        sorted_by_username_asc = User.select(:username).where(status: 1).order(username: :asc).first
        sorted_by_username_desc = User.select(:username).where(status: 1).order(username: :desc).first

        within '#table_results' do
          click_button 'Usuario'
          sleep 1
        end

        within '#users' do
          expect(page.first('tr').first('td:nth-child(2)')).to have_content(sorted_by_username_asc.username)
        end

        within '#table_results' do
          click_button 'Usuario'
          sleep 1
        end

        within '#users' do
          expect(page.first('tr').first('td:nth-child(2)')).to have_content(sorted_by_username_desc.username)
        end
      end

      it 'by name' do
        sorted_by_name_asc = User.joins(:profile).where(status: 1).order(first_name: :asc).first

        sorted_by_name_desc = User.joins(:profile).where(status: 1).order(first_name: :desc).first

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#users' do
          expect(page.first('tr').find('td:nth-child(4)')).to have_text(sorted_by_name_asc.first_name)
        end

        within '#table_results' do
          click_button 'Nombre'
          sleep 1
        end

        within '#users' do
          expect(page.first('tr').find('td:nth-child(4)')).to have_text(sorted_by_name_desc.first_name)
        end
      end
    end

    # describe 'Destroy permission' do
    #   before(:each) do
    #     @user_to_del = users_without_stock.sample
    #     within 'users-filter' do
    #       fill_in 'filter[name]', with: @user_to_del.name
    #       click_button 'Buscar'
    #       sleep 1
    #     end
    #   end

    #   it 'has button destroy' do
    #     within 'users' do
    #       expect(page).to have_selector('button.delete-item')
    #     end
    #   end

    #   it 'shown modal on button destroy click' do
    #     within 'users' do
    #       page.first('button.delete-item').click
    #       sleep 1
    #     end
    #     within '#delete-item' do
    #       expect(page).to have_content('Eliminar usero')
    #       expect(page).to have_button('Volver')
    #       expect(page).to have_link('Confirmar')
    #     end
    #   end

    #   it 'destroy items' do
    #     within 'users' do
    #       page.first('button.delete-item').click
    #       sleep 1
    #     end
    #     within '#delete-item' do
    #       click_link 'Confirmar'
    #       sleep 1
    #     end
    #     expect(page).to have_text("El suministro #{@user_to_del.name} se ha eliminado correctamente.")
    #   end
    # end
  end
end
