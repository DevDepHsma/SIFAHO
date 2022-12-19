#  Test information

#  Testing modules:
#  Access permissions: List
#  Filter by: Remit code / Applicant / Origin / Status
#  Sort by: Remit code / Applicant
#  Pagination
#  Delete action
#  Nullify action
#

require 'rails_helper'

RSpec.feature 'InternalOrdersProviderFiltersSpec.rbs', type: :feature do
  before(:all) do
    permission_module = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Proveedor')
    @read_internal_order_provider = permission_module.permissions.find_by(name: 'read_internal_order_provider')
    @destroy_internal_order_provider = permission_module.permissions.find_by(name: 'destroy_internal_order_provider')
    @nullify_internal_order_provider = permission_module.permissions.find_by(name: 'nullify_internal_order_provider')
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @read_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @destroy_internal_order_provider)
    PermissionUser.create(user: @farm_applicant, sector: @farm_applicant.active_sector,
                          permission: @nullify_internal_order_provider)
  end

  background do
    sign_in @farm_applicant
  end

  describe '', js: true do
    subject { page }

    before(:each) do
      visit '/sectores/pedidos/despachos'
    end

    describe 'form filters' do
      it 'has fields' do
        within '#internal-filter' do
          expect(page).to have_field('filter[code]', type: 'text')
          expect(page).to have_field('filter[search_applicant]', type: 'text')
          expect(page).to have_button('Buscar')
          expect(page).to have_selector('button.btn-clean-filters')
        end
      end

      it 'by code' do
        internal_orders = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#internal-filter' do
            fill_in 'filter[code]', with: internal_order.remit_code
            click_button 'Buscar'
            sleep 1
          end
          within '#internal_orders' do
            expect(page.first('tr').first('td')).to have_selector('mark.highlight-1',
                                                                  text: internal_order.remit_code)
          end
          within '#internal-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by applicant' do
        internal_orders = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#internal-filter' do
            fill_in 'filter[search_applicant]', with: internal_order.applicant_sector.name
            click_button 'Buscar'
            sleep 1
          end
          within '#internal_orders' do
            expect(page.first('tr').find('td:nth-child(2)')).to have_selector('mark.highlight-1',
                                                                              text: internal_order.applicant_sector.name)
          end
          within '#internal-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
      it 'by order_type ' do
        internal_orders = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#internal-filter' do
            page.select internal_order.order_type, from: 'filter[with_order_type]'
            click_button 'Buscar'
            sleep 1
          end
          within '#internal_orders' do
            expect(page.first('tr').find('td:nth-child(3)')).to have_content(internal_order.order_type.capitalize)
          end
          within '#internal-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end

      it 'by status' do
        internal_orders = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant).sample(5)
        internal_orders.each do |internal_order|
          within '#internal-filter' do
            page.select internal_order.status, from: 'filter[with_status]'
            click_button 'Buscar'
            sleep 1
          end
          within '#internal_orders' do
            expect(page.first('tr').find('td:nth-child(4)')).to have_content(internal_order.status.capitalize.gsub('_',
                                                                                                                   ' '))
          end
          within '#internal-filter' do
            page.first('button.btn-clean-filters').click
            sleep 1
          end
        end
      end
    end

    describe 'pagination' do
      before(:each) do
        internal_orders = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant)
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
        within '#internal_orders' do
          expect(page).to have_selector('tr', count: 15)
        end
      end

      it 'change items per page to 30' do
        within '#paginate_footer' do
          page.select '30', from: 'page-size-selection'
          sleep 1
        end
        within '#internal_orders' do
          expect(page).to have_selector('tr', count: 30)
        end
      end
    end

    describe 'Sort' do
      it 'has sort buttons' do
        within '#table_results thead' do
          expect(page).to have_button('Código')
          expect(page).to have_button('Solicitante')
        end
      end

      it 'by code' do
        internal_orders = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant)
        sorted_by_code_asc = internal_orders.order(remit_code: :asc).first
        sorted_by_code_desc = internal_orders.order(remit_code: :desc).first

        within '#table_results' do
          click_button 'Código'
          sleep 1
        end

        within '#internal_orders' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_asc.remit_code)
        end

        within '#table_results' do
          click_button 'Código'
          sleep 1
        end

        within '#internal_orders' do
          expect(page.first('tr').first('td')).to have_content(sorted_by_code_desc.remit_code)
        end
      end

      it 'by applicant' do
        sorted_by_applicant_asc = InternalOrder.select('sectors.name as name').by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant).order('sectors.name asc').first

        sorted_by_applicant_desc = InternalOrder.select('sectors.name as name').by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant).order('sectors.name desc').first

        within '#table_results' do
          click_button 'Solicitante'
          sleep 1
        end
        within '#internal_orders' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_applicant_asc.name)
        end

        within '#table_results' do
          click_button 'Solicitante'
          sleep 1
        end

        within '#internal_orders' do
          expect(page.first('tr').find('td:nth-child(2)')).to have_text(sorted_by_applicant_desc.name)
        end
      end
    end

    describe 'Destroy permission' do
      before(:each) do
        internal_order = InternalOrder.by_provider(@farm_applicant.active_sector.id).where(provider_sector_id: @farm_applicant,
                                                                                           status: 'proveedor_auditoria', order_type: 'provision').sample
        within '#internal-filter' do
          fill_in 'filter[code]', with: internal_order.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has button destroy' do
        within '#internal_orders' do
          expect(page).to have_selector('button.delete-item')
        end
      end

      it 'shown modal on button destroy click' do
        within '#internal_orders' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          expect(page).to have_content('Eliminar provisión')
          expect(page).to have_button('Volver')
          expect(page).to have_link('Confirmar')
        end
      end

      it 'destroy order' do
        within '#internal_orders' do
          page.first('button.delete-item').click
          sleep 1
        end
        within '#delete-item' do
          click_link 'Confirmar'
          sleep 1
        end
        expect(page).to have_text('El pedido interno de se ha eliminado correctamente.')
      end
    end

    describe 'Nullify permission' do
      before(:each) do
        @order = InternalOrder.by_provider(@farm_applicant.active_sector.id).solicitud.solicitud_enviada.where(provider_sector_id: @farm_applicant).sample
        within '#internal-filter' do
          fill_in 'filter[code]', with: @order.remit_code
          click_button 'Buscar'
          sleep 1
        end
      end

      it 'has nullify button' do
        within '#internal_orders' do
          expect(page).to have_selector 'button.btn-nullify'
        end
      end

      it 'shown modal on button nullify click' do
        within '#internal_orders' do
          page.first('button.btn-nullify').click
          sleep 1
        end
        within "#anular-confirm" do
          expect(page).to have_text 'Confirmar anulación de orden'
          expect(page).to have_text "Esta seguro de anular el pedido #{@order.remit_code} de #{@order.applicant_sector.name}?"
          expect(page).to have_link 'Cancelar'
          expect(page).to have_link 'Anular'
        end
      end

      it 'nullify order' do
        within '#internal_orders' do
          page.first('button.btn-nullify').click
          sleep 1
        end
        within "#anular-confirm" do
          click_link 'Anular'
        end
        sleep 1
        expect(page).to have_text 'Solicitud se ha anulado correctamente.'
        expect(page).to have_text "Viendo solicitud #{@order.remit_code}"
        expect(page).to have_text 'Anulado'
      end
    end
  end
end
