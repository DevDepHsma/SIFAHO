require 'rails_helper'

RSpec.feature 'ExternalOrdersApplicantFilters', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Externas Solicitud')
    @read_external_order_applicant = permission_module.permissions.find_by(name: 'read_external_order_applicant')
    @update_external_order_applicant = permission_module.permissions.find_by(name: 'update_external_order_applicant')
    @destroy_external_order_applicant = permission_module.permissions.find_by(name: 'destroy_external_order_applicant')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_external_order_applicant)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @destroy_external_order_applicant)
  end

  background do
    sign_in @farm_applicant
  end

  describe '', js: true do
    subject { page }

    before(:each) do
      visit '/establecimientos/pedidos/recibos'
    end

    describe 'form filters' do
      it 'has fields' do
        within '#external-orders-filter' do
          expect(page).to have_field('filter[code]', type: 'text')
          expect(page).to have_field('filter[provider]', type: 'text')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end

      it 'by code' do
        internal_orders = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(applicant_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#external-orders-filter' do
            fill_in 'filter[code]', with: internal_order.remit_code
            click_button 'Buscar'
            sleep 1
          end
          within '#external_orders' do
            expect(page.first('tr').first('td')).to have_selector('mark.highlight-1',
                                                                  text: internal_order.remit_code)
          end
          within '#external-orders-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by provider' do
        internal_orders = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(applicant_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#external-orders-filter' do
            fill_in 'filter[provider]', with: internal_order.provider_sector.name
            click_button 'Buscar'
            sleep 1
          end
          within '#external_orders' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1',
                                                                              text: internal_order.provider_sector.name)
          end
          within '#external-orders-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
      it 'by order_type ' do
        internal_orders = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(applicant_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#external-orders-filter' do
            page.select internal_order.order_type, from: 'filter[with_order_type]'
            click_button 'Buscar'
            sleep 1
          end
          within '#external_orders' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_content(internal_order.order_type.capitalize)
          end
          within '#external-orders-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by status' do
        internal_orders = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(applicant_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#external-orders-filter' do
            page.select internal_order.status, from: 'filter[with_status]'
            click_button 'Buscar'
            sleep 1
          end
          within '#external_orders' do
            expect(page.first('tr').find('td:nth-child(4)')).to have_content(internal_order.status.capitalize.gsub('_',
                                                                                                                   ' '))
          end
          within '#external-orders-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end

    describe 'pagination' do
      before(:each) do
        internal_orders = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(applicant_sector_id: @farm_applicant)
        @last_page = (internal_orders.all.count / 15.to_f).ceil
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
        within '#external_orders' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#external_orders' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Código')
          expect(page).to have_button('Proveedor')
        end
      end

      it 'by remit_code' do
        external_orders = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(applicant_sector_id: @farm_applicant)
        sorted_by_code_asc = external_orders.order(remit_code: :asc).first
        sorted_by_code_desc = external_orders.order(remit_code: :desc).first

        within '#table_results' do
          click_button 'Código'
          sleep 1
        end

        within '#external_orders' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_asc.remit_code)
        end

        within '#table_results' do
          click_button 'Código'
          sleep 1
        end

        within '#external_orders' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_desc.remit_code)
        end
      end

      it 'by provider' do
        sorted_by_provider_asc = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).order('sectors.name asc').first

        sorted_by_provider_desc = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).order('sectors.name desc').first

        within '#table_results' do
          click_button 'Proveedor'
          sleep 1
        end

        within '#external_orders' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_provider_asc.provider_sector.name)
        end

        within '#table_results' do
          click_button 'Proveedor'
          sleep 1
        end

        within '#external_orders' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_provider_desc.provider_sector.name)
        end
      end
    end

    describe 'Destroy permission' do
      it 'has button destroy' do
        external_order = ExternalOrder.by_applicant(@farm_applicant.active_sector.id).where(
          applicant_sector_id: @farm_applicant, status: 'solicitud_auditoria'
        ).sample
        within '#external-orders-filter' do
          fill_in 'filter[code]', with: external_order.remit_code
          click_button 'Buscar'
          sleep 1
        end
        within '#external_orders' do
          expect(page).to have_selector('button.delete-item')
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar solicitud')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
          click_link 'Confirmar'
          sleep 1
        end
        sleep 1
        expect(page).to have_text("Solicitud de #{external_order.applicant_sector.name} se ha enviado a la papelera.")
      end
    end
  end
end
