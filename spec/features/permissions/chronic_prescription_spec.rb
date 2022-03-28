require 'rails_helper'

RSpec.feature "Permissions::ChronicPrescriptions", type: :feature do
  
  before(:all) do
    @user = create(:user_1)
    @permission_module = create(:permission_module, name: 'Recetas Ambulatorias')
    @read_chronic_recipe_permission = create(:permission, name: 'read_chronic_prescriptions', permission_module: @permission_module)
    @create_chronic_recipe_permission = create(:permission, name: 'create_chronic_prescriptions', permission_module: @permission_module)

    # Create scenario with professional form completed
    @professionals_permission_module = create(:permission_module, name: 'Profesionales')
    @create_professional_permission = create(:permission, name: 'create_professionals', permission_module: @professionals_permission_module)
    PermissionUser.create(user: @user, sector: @user.sector, permission: @create_professional_permission)
    product = create(:unidad_product)
    lot = create(:province_lot_without_product, product: product)
    stock = create(:stock, product: product, sector: @user.sector)
    @lot_stock = LotStock.create(quantity: 1500, lot: lot, stock: stock)
  end

  background do
    sign_in_as(@user)
  end

  describe 'Chronic Recipes ::', js: true do
    subject { page }

    it 'does not show "Recetas" link' do
      visit '/'
      expect(page).to_not have_selector(:css, "a[href='#{new_prescription_path}']")
    end

    describe 'Add permissions ::' do
      before(:each) do
        PermissionUser.create(user: @user, sector: @user.sector, permission: @read_chronic_recipe_permission)
      end

      it 'can READ' do
        visit '/'
        expect(page).to have_selector(:css, "a[href='#{new_prescription_path}']")
      end
      
      describe 'CREATE ::' do
        before(:each) do
          visit '/'
          click_link 'Recetas'
          find_or_create_patient_by_dni('Crónicas', '37458994')          
        end

        it 'does not show create chronic recipe' do
          expect(page.has_css?('#new-chronic')).to be false
        end
        
        describe '' do
          before(:each) do
            PermissionUser.create(user: @user, sector: @user.sector, permission: @create_chronic_recipe_permission)
            find_or_create_professional_by_enrollment(@user, '#new-chronic', 'Naval')
          end

          it 'successfully' do
            add_create_product_by_code('0000', 100, 100)
            click_button 'Dispensar'
            expect(page).to have_content('Viendo receta ambulatoria')
            expect(page.has_link?('Volver')).to be true
            expect(page.has_link?('Imprimir')).to be true
            expect(page.has_button?('Retornar')).to be false
            expect(page.has_link?('Dispensar')).to be false
            expect(page.has_link?('Editar')).to be false
          end
        end
      end
    end

  end
end
