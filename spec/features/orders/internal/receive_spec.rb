#  Test information

#  Testing modules:
#  Access permissions: List / Show
#  Receive Internal Order
#

require 'rails_helper'

RSpec.feature 'Orders::Internal::Receives', type: :feature do
  before(:all) do
    permission_module_applicant = PermissionModule.includes(:permissions).find_by(name: 'Ordenes Internas Solicitud')
    permission_module_applicant.permissions.map do |permission|
      PermissionUser.create(user: @depo_applicant, sector: @depo_applicant.active_sector, permission: permission)
    end
  end

  background do
    sign_in @depo_applicant
  end

  describe 'Permissions::Receive order', js: true do
    subject { page }

    it 'click "Recibir" open a receive modal' do
      order = InternalOrder.provision_en_camino.where(applicant_sector: @depo_applicant.active_sector).sample
      visit "/sectores/pedidos/recibos/#{order.id}"
      expect(page).to have_button 'Recibir'
      click_button 'Recibir'
      sleep 1
      expect(page).to have_css '#receive-confirm', visible: true
      within '#receive-confirm' do
        expect(page).to have_text 'Confirmar recibo de pedido de sector'
        expect(page).to have_text "Esta seguro que ha recibido el pedido código #{order.remit_code}?"
        expect(page).to have_link 'Cancelar'
        expect(page).to have_link 'Confirmar'
      end
    end

    it 'receive action' do
      order = InternalOrder.provision_en_camino.where(applicant_sector: @depo_applicant.active_sector).sample
      visit "/sectores/pedidos/recibos/#{order.id}"
      click_button 'Recibir'
      sleep 1
      click_link 'Confirmar'
      sleep 1
      expect(page).to have_text 'La solicitud se ha recibido correctamente'
      expect(page).to have_text 'Provision entregada'
      expect(page).to_not have_button 'Recibir'
    end
  end
end
