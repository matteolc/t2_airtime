require 'rails_helper'
require 't2_airtime'

RSpec.describe T2Airtime do
  it 'serializes account information' do
    info = T2Airtime::Account.info
    expect(info['attributes']['type']).to eq('Master')
  end

  it 'serializes at least 1 transaction' do
    at_least_five_items = T2Airtime::Transaction.take
  end

  it 'serializes at least 5 products' do
    five_items = T2Airtime::Product.take
    expect(five_items.count).to be > 4
  end

  it 'serializes all countries' do
    items = T2Airtime::Country.take(nil)
    expect(items.count).to be > 5
  end

  it 'serializes 5 countries' do
    five_items = T2Airtime::Country.take
    expect(five_items.count).to eq(5)
  end

  it 'serializes at least 1 up to 5 operators' do
    at_least_five_items = T2Airtime::Operator.take
    expect(at_least_five_items.count).to be > 1
    expect(at_least_five_items.count).to be < 6
  end

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

  it 'responds to ping' do
    api = T2Airtime::API.api
    expect(api.ping.message).to eq('pong')
  end

  it 'gets account information' do
    api = T2Airtime::API.api
    expect(api.account_info.error_code).to eq(0)
  end

  it 'checks number information' do
    api = T2Airtime::API.api
    reply = api.msisdn_info(T2Airtime::Util.test_numbers(2))
    expect(reply.success?).to eq(true)
    expect(reply.data[:country]).to eq('Indonesia')
  end

  it 'reserves a transaction id' do
    api = T2Airtime::API.api
    reply = api.reserve_id
    expect(reply.success?).to eq(true)
    expect(reply.data[:reserved_id]).not_to be nil
  end

  it 'returns a countries list' do
    api = T2Airtime::API.api
    reply = api.country_list
    expect(reply.success?).to eq(true)
    expect(reply.data[:country].split(',').count).to be(reply.data[:countryid].split(',').count)
  end

  it 'returns a country operators' do
    api = T2Airtime::API.api
    country_id = api.msisdn_info(T2Airtime::Util.test_numbers(2)).data[:countryid]
    reply = api.operator_list(country_id)
    expect(reply.success?).to eq(true)
    expect(reply.data[:operator].split(',').count).to be(reply.data[:operatorid].split(',').count)
  end

  it 'returns an operator products' do
    api = T2Airtime::API.api
    operator_id = api.msisdn_info(T2Airtime::Util.test_numbers(2)).data[:operatorid]
    reply = api.product_list(operator_id)
    expect(reply.success?).to eq(true)
    expect(reply.data[:product_list].split(',').count).to be(reply.data[:wholesale_price_list].split(',').count)
    expect(reply.data[:product_list].split(',').count).to be(reply.data[:retail_price_list].split(',').count)
  end

  # The method simulation takes the same parameters as topup method. It does not perform a real Top-up to the destination number.
  # This action will test if the destination number is in TransferTo numbering plan, and if the product specified is valid.
  # • It DOES NOT verify if the destination number has expired  for instance as the request is
  # not submitted to the operator. Thus, a simulation can be successful, while a real top-up
  # (request sent to the operator to perform both debit and Top-up) can fail.
  # • For PIN Based products, API will respond basics information  (PIN Less like). All parameters
  # related to PIN information will not be provided in the response.
  # Note that this action will provide you with some information (products available in your account) but is
  # not part of the Top-up cycle. You should perform Top-up without making any simulations before.

  it 'returns error code 0 for PIN based Top-up (successful transaction)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(1)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(true)
  end

  it 'returns error code 0 for PIN less Top-up (successful transaction)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(2)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(true)
  end

  it 'returns error code 204 (destination number is not a valid prepaid phone number)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(3)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(false)
    expect(reply.error_code).to eq(204)
  end

  it 'returns error code 301 (input value out of range or invalid product)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(4)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(false)
    expect(reply.error_code).to eq(301)
  end

  it 'returns error code 214 (transaction refused by the operator)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(5)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(false)
    expect(reply.error_code).to eq(214)
  end

  it 'returns error code 998 (system not available, please retry later)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(6)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(false)
    expect(reply.error_code).to eq(998)
  end

  it 'returns error code 999 (unknown error, please contact support)' do
    api = T2Airtime::API.api
    to_number = T2Airtime::Util.test_numbers(7)
    operator_id = api.msisdn_info(to_number).data[:operatorid]
    product = api.product_list(operator_id).data[:product_list].split(',')[0]
    reply = api.topup('anumber', to_number, product, 'simulation')
    expect(reply.success?).to eq(false)
    expect(reply.error_code).to eq(999)
  end

  it 'returns a transaction list' do
    api = T2Airtime::API.api
    reply = api.transaction_list(Time.now.beginning_of_day, Time.now.end_of_day)
    expect(reply.success?).to eq(true)
  end
end
