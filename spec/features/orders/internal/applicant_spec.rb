require 'rails_helper'

RSpec.feature 'Orders::Internal::Applicants', type: :feature do
  before(:all) do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Ordenes Internas Solicitud')
    @read_internal_order_applicant = create(:permission, name: 'read_internal_order_applicant', permission_module: @permission_module)
    @create_internal_order_applicant = create(:permission, name: 'create_internal_order_applicant', permission_module: @permission_module)
    @update_internal_order_applicant = create(:permission, name: 'update_internal_order_applicant', permission_module: @permission_module)
    @destroy_internal_order_applicant = create(:permission, name: 'destroy_internal_order_applicant', permission_module: @permission_module)
    @send_internal_order_applicant = create(:permission, name: 'send_internal_order_applicant', permission_module: @permission_module)
    @receive_internal_order_applicant = create(:permission, name: 'receive_internal_order_applicant', permission_module: @permission_module)
    @return_internal_order_applicant = create(:permission, name: 'return_internal_order_applicant', permission_module: @permission_module)

    @products = get_products
    @unity = create(:unidad_unity)
    @area = create(:medication_area)
    @lab = create(:abbott_laboratory)
    @products.each_with_index do |product, index|
      prod = create(:product, name: product[0], code: product[1], area: @area, unity: @unity)
      lot = create(:lot, laboratory: @lab, product: prod, code: "BB-#{index}", expiry_date:  Date.today + 15.month)
      stock = create(:stock, product: prod, sector: @user.sector)
      LotStock.create(quantity: rand(1500..5000), lot: lot, stock: stock)
    end
  end

  background do
    sign_in_as(@user)
  end

  describe 'InternalOrder :: Permissions', js: true do
    subject { page }

    it ':: READ :: FAIL' do
      expect(page.has_link?('Sectores')).to_not be true
    end

  end
end
