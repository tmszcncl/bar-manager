require 'rails_helper'

RSpec.describe "orders/index", type: :view do
  before(:each) do
    assign(:orders, [
      Order.create!(
        :step => "Step"
      ),
      Order.create!(
        :step => "Step"
      )
    ])
  end

  it "renders a list of orders" do
    render
    assert_select "tr>td", :text => "Step".to_s, :count => 2
  end
end
