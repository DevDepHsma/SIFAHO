require 'rails_helper'

RSpec.describe "unify_products/edit", type: :view do
  before(:each) do
    @unify_product = assign(:unify_product, UnifyProduct.create!(
      :origin_product => nil,
      :target_product => nil,
      :status => 1,
      :observation => "MyText"
    ))
  end

  it "renders the edit unify_product form" do
    render

    assert_select "form[action=?][method=?]", unify_product_path(@unify_product), "post" do

      assert_select "input[name=?]", "unify_product[origin_product_id]"

      assert_select "input[name=?]", "unify_product[target_product_id]"

      assert_select "input[name=?]", "unify_product[status]"

      assert_select "textarea[name=?]", "unify_product[observation]"
    end
  end
end
