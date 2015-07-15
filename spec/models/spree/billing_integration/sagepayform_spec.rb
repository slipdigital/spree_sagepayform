require 'spec_helper'

RSpec.describe Spree::BillingIntegration::Sagepayform do

  before do
    require 'ostruct'

    # FactoryGirl.create(:calc_01)
    @zone = FactoryGirl.create(:zone_01)
    @shipping_method = FactoryGirl.create(:shipping_method_01)
    @product_01 = FactoryGirl.create(:product_01)
    @product_02 = FactoryGirl.create(:product_01)
    @product_03 = FactoryGirl.create(:product_01, :available_on => Date.today + 10.days)
    @order = FactoryGirl.create(:order_01)
  end

  it 'creates the correct string' do
     spf = Spree::BillingIntegration::Sagepayform.new()
    expect(spf.provider_class).to eq(ActiveMerchant::Billing::Integrations::SagePayFormV3)
  end

  it 'returns the correct value for source_required?' do
    spf = Spree::BillingIntegration::Sagepayform.new()
    expect(spf.source_required?).to eq(true)

  end
end