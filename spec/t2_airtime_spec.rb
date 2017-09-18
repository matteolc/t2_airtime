require 'rails_helper'
require 't2_airtime'

RSpec.describe T2Airtime do

  describe "Gem" do

    it 'has a version number' do
      expect(T2Airtime::VERSION).not_to be nil
    end
  
    it 'has the correct API URL' do
      expect(T2Airtime::DOMAIN).to eq('transferto.com')
      expect(T2Airtime::ENDPOINT).to eq('cgi-bin/shop/topup')
    end

    it 'has 7 test numbers' do
      expect(T2Airtime::Util.test_numbers.length).to eq(7)
    end

  end

  describe "Serializer" do

    before(:each) do
      Rails.cache.clear
    end  

    it 'serializes account information' do    
      info = T2Airtime::Account.info
      expect(info[:attributes][:type]).to eq('Master')
    end
    
    it 'serializes all countries' do
      items = T2Airtime::Country.take('all')
      expect(items.count).to be > 5
    end  

    it 'serializes 5 countries' do
      five_items = T2Airtime::Country.take(5)
      expect(five_items.count).to eq(5)
    end
  
    it 'serializes 5 operators' do
      five_items = T2Airtime::Operator.take(1,5) # 5 countries, 1 operator each
      expect(five_items.count).to eq(5)
    end  
  
    it 'serializes 5 products' do
      five_items = T2Airtime::Product.take(1,1,5) # 5 countries, 1 operator per country, 1 product per operator
      expect(five_items.count).to eq(5)
    end    
    
  end

  describe "api" do

    before(:each) do
      @api = T2Airtime::API.api
    end 

    it 'responds to ping' do    
      expect(@api.ping.message).to eq('pong')
    end

    it 'returns a countries list' do
      reply = @api.country_list
      expect(reply.success?).to eq(true)
      expect(reply.data[:country].split(',').count).to be(reply.data[:countryid].split(',').count)
    end

    it 'returns a country operators' do
      country_id = @api.msisdn_info(T2Airtime::Util.test_numbers(2)).data[:countryid]
      reply = @api.operator_list(country_id)
      expect(reply.success?).to eq(true)
      expect(reply.data[:operator].split(',').count).to be(reply.data[:operatorid].split(',').count)
    end

    it 'returns an operator products' do
      operator_id = @api.msisdn_info(T2Airtime::Util.test_numbers(2)).data[:operatorid]
      reply = @api.product_list(operator_id)
      expect(reply.success?).to eq(true)
      expect(reply.data[:product_list].split(',').count).to be(reply.data[:wholesale_price_list].split(',').count)
      expect(reply.data[:product_list].split(',').count).to be(reply.data[:retail_price_list].split(',').count)
    end  

    it 'checks number information' do    
      reply = @api.msisdn_info(T2Airtime::Util.test_numbers(2))
      expect(reply.success?).to eq(true)
      expect(reply.data[:country]).to eq('Indonesia')
    end

    it 'reserves a transaction id' do
      reply = @api.reserve_id
      expect(reply.success?).to eq(true)
      expect(reply.data[:reserved_id]).not_to be nil
    end

    it 'returns error code 0 for PIN based Top-up (successful transaction)' do
      to_number = T2Airtime::Util.test_numbers(1)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(true)
      expect(reply.error_code).to eq(0)
    end

    it 'returns error code 0 for PIN less Top-up (successful transaction)' do
      to_number = T2Airtime::Util.test_numbers(2)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(true)
      expect(reply.error_code).to eq(0)
    end

    it 'returns error code 204 (destination number is not a valid prepaid phone number)' do
      to_number = T2Airtime::Util.test_numbers(3)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(false)
      expect(reply.error_code).to eq(204)
    end

    it 'returns error code 301 (input value out of range or invalid product)' do
      to_number = T2Airtime::Util.test_numbers(4)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(false)
      expect(reply.error_code).to eq(301)
    end

    it 'returns error code 214 (transaction refused by the operator)' do
      to_number = T2Airtime::Util.test_numbers(5)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(false)
      expect(reply.error_code).to eq(214)
    end

    it 'returns error code 998 (system not available, please retry later)' do
      to_number = T2Airtime::Util.test_numbers(6)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(false)
      expect(reply.error_code).to eq(998)
    end

    it 'returns error code 999 (unknown error, please contact support)' do
      to_number = T2Airtime::Util.test_numbers(7)
      operator_id = @api.msisdn_info(to_number).data[:operatorid]
      product = @api.product_list(operator_id).data[:product_list].split(',')[0]
      reply = @api.topup('anumber', to_number, product, 'topup')
      expect(reply.success?).to eq(false)
      expect(reply.error_code).to eq(999)
    end

    it 'returns a transaction list' do
      reply = @api.transaction_list(Time.now.beginning_of_day, Time.now.end_of_day)
      expect(reply.success?).to eq(true)
    end

  end
end
