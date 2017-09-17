module T2Airtime

  class Topup

    def self.serialize(data, ts = Time.zone.now.to_s)
      {
        type: 'topup',
        balance: data[:balance],
        balanceDisplay: "#{Money.new(Integer(data[:balance]) * 100, Account.currency).format}",
        msisdn: data[:destination_msisdn],
        destinationMsisdn: data[:destination_msisdn],
        transactionId: data[:transactionid],
        transactionAuthenticationKey: data[:authentication_key],
        transactionErrorCode: Integer(data[:error_code]),
        transactionErrorTxt: data[:error_txt],
        referenceOperator: data[:reference_operator],
        actualProductSent: data[:actual_product_sent],
        sms: data[:sms],
        smsSent: data[:sms_sent],
        cid1: data[:cid1],
        cid2: data[:cid2],
        cid3: data[:cid3],
        currency: data[:originating_currency],
        localCurrency: data[:destination_currency],
        countryId: Integer(data[:countryid]), 
        countryName: data[:country],
        operatorId: Integer(data[:operatorid]),
        operatorName: data[:operator],
        operatorLogo: T2Airtime::Util.operator_logo_url(data[:operatorid]),  
        productName: "#{Money.new(Integer(data[:product_requested]) * 100, data[:destination_currency]).format}",
        productLocalCurrency: data[:destination_currency],
        productLocalCurrencySymbol: Money::Currency.new(data[:destination_currency]).symbol,
        productCurrency: Account.currency,
        productCurrencySymbol: Money::Currency.new(Account.currency).symbol,
        productLocalPrice: Float(data[:product_requested]),
        productRetailPrice: Float(data[:retail_price]),
        productWholesalePrice: Float(data[:wholesale_price]),  
        executedAt: T2Airtime::Util.format_time(ts)
      }
    end

  end


  class Msisdn

    def self.info(msisdn)
      Rails.cache.fetch("msisdn/#{msisdn}", expires_in: 24.hours) do # cache the result for 1 day
        T2Airtime::API.api.msisdn_info(msisdn)
      end
    end

    def self.serialize(data, ts = Time.zone.now.to_s)
      {
        type: 'msisdn',
        msisdn: data[:destination_msisdn],
        country: data[:country],
        countryId: data[:countryid],
        operator: data[:operator],
        operatorId: data[:operatorid],
        fetchedAt: T2Airtime::Util.format_time(ts)
      }
    end

  end

  class Account
    def self.get
      Rails.cache.fetch('accounts', expires_in: 1.hour) do
        T2Airtime::API.api.account_info
      end
    end

    def self.currency
      account = serialize(get.data)
      Rails.cache.fetch('accounts/currency', expires_in: 24.hours) do # cache the result for 1 day        
        account[:attributes][:currency]
      end      
    end

    def self.info
      get.success? ? serialize(get.data, get.headers[:date]) : []
    end

    def self.serialize(data, ts = Time.zone.now.to_s)
      {
        type: 'accounts',
        id: T2Airtime::API.api.user,
        attributes: {
          type: data[:type],
          name: data[:name],
          currency: data[:currency],
          balance: Float(data[:balance]),
          wallet: Float(data[:wallet]),
          fetchedAt: T2Airtime::Util.format_time(ts)
        }
      }
    end
  end

  class Country
    def self.all
      Rails.cache.fetch('countries', expires_in: 1.hour) do
        T2Airtime::API.api.country_list
      end
    end

    def self.take(qty = 5)
      countries = all
      countries.success? ? serialize(countries.data, countries.headers[:date], qty) : []
    end

    def self.serialize(data, ts = Time.zone.now.to_s, qty = nil)
      return [] if data[:countryid].nil?
      names = data[:country].split(',')
      ids = data[:countryid].split(',')
      Rails.cache.fetch('countries/serializer', expires_in: 1.hour) do
        ids.take(qty.nil? ? ids.count : qty).each_with_index.map do |id, n|
          {
            type: 'countries',
            id: Integer(id),
            attributes: {
              name: names[n],
              alpha3: alpha3(names[n]),
              callingCode: calling_code(alpha3(names[n])),
              fetchedAt: T2Airtime::Util.format_time(ts)
            }
          }
        end
      end
    end

    def self.normalize(name)
      name.starts_with?('St') ? name.gsub('St', 'Saint') : name
    end

    def self.alpha3(name)
      alpha3 = ISO3166::Country.find_country_by_name(name).try(:alpha3)
      unless alpha3
        alpha3 = case name
                 when 'Saint Vincent Grenadines'
                   'VCT'
                 when 'Kosovo'
                   'UNK'
                 when 'Netherlands Antilles'
                   'ANT'
                 when 'Serbia and Montenegro'
                   'SCG'
        end
        register_alpha3(alpha3, name) if %w[VCT UNK ANT SCG].include?(alpha3)
      end
      alpha3 || 'XXX'
    end

    def self.register_alpha3(alpha3, name)
      ISO3166::Data.register(
        alpha2: 'XX',
        alpha3: alpha3,
        name: name
      )
    end

    def self.calling_code(alpha3)  
      country_code = case alpha3
          when 'PCN'
            '64'
          when 'ATF'
            '262'            
      end
      country_code || ISO3166::Country.find_country_by_alpha3(alpha3).try(:country_code)       
    end

  end

  class Operator
    def self.all(country_id)
      Rails.cache.fetch("operators/#{country_id}", expires_in: 1.hour) do
        T2Airtime::API.api.operator_list(country_id)
      end
    end

    def self.take(country_qty = 1, qty = 5)
      countries = T2Airtime::Country.take(country_qty).shuffle
      unless countries.empty?
        countries.flat_map do |country| (          
          operators = all(country['id'])
          operators.success? ? serialize(operators.data, operators.headers[:date], qty) : []
        )
        end
      end
    end

    def self.serialize(data, ts = Time.zone.now.to_s, qty = nil)
      return [] if data[:operator].nil?
      names = data[:operator].split(',')
      ids = data[:operatorid].split(',')
      Rails.cache.fetch("operators/#{data[:countryid]}/serializer", expires_in: 1.hour) do
        ids.take(qty.nil? ? ids.count : qty).each_with_index.map do |id, n|
          {
            type: 'operators',
            id: Integer(id),
            attributes: {
              name: names[n],
              logo: T2Airtime::Util.operator_logo_url(id),
              countryId: Integer(data[:countryid]), 
              countryName: data[:country],
              countryAlpha3: T2Airtime::Country.alpha3(data[:country]),              
              fetchedAt: T2Airtime::Util.format_time(ts)
            },
            relationships: {
              country: {
                data: {
                  type: 'countries',
                  id: Integer(data[:countryid])
                }
              }
            }
          }
        end
      end
    end
  end

  class Product
    def self.all(operator_id)
      Rails.cache.fetch("products/#{operator_id}", expires_in: 1.hour) do
        T2Airtime::API.api.product_list(operator_id)
      end
    end

    def self.take(operator_qty = 1, qty = 5)
      operators = T2Airtime::Operator.take(operator_qty).shuffle
      unless operators.empty?
        operators.flat_map do |operator| (          
          products = all(operator['id'])
          products.success? ? serialize(products.data, products.headers[:date], qty) : []
        )
        end
      end
    end

    def self.serialize(data, ts = Time.zone.now.to_s, qty = nil)
      return [] if data[:product_list].nil?
      ids = data[:product_list].split(',')
      retail_prices = data[:retail_price_list].split(',')
      wholesale_prices = data[:wholesale_price_list].split(',')
      Rails.cache.fetch("products/#{data[:operatorid]}/serializer", expires_in: 1.hour) do
        ids.take(qty.nil? ? ids.count : qty).each_with_index.map do |id, n|
          {
            type: 'products',
            id: Integer(id),
            attributes: {
              name: "#{Money.new(Integer(id) * 100, data[:destination_currency]).format}",
              localCurrency: data[:destination_currency],
              localCurrencySymbol: Money::Currency.new(data[:destination_currency]).symbol,
              currency: Account.currency,
              currencySymbol: Money::Currency.new(Account.currency).symbol,
              localPrice: Float(id),
              retailPrice: Float(retail_prices[n]),
              wholesalePrice: Float(wholesale_prices[n]),
              countryId: Integer(data[:countryid]), 
              countryName: data[:country],
              countryAlpha3: T2Airtime::Country.alpha3(data[:country]),
              operatorId: Integer(data[:operatorid]),
              operatorName: data[:operator],
              operatorLogo: T2Airtime::Util.operator_logo_url(data[:operatorid]),                      
              fetchedAt: T2Airtime::Util.format_time(ts)
            },
            relationships: {
              country: {
                data: {
                  type: 'countries',
                  id: Integer(data[:countryid])
                }
              },
              operator: {
                data: {
                  type: 'operators',
                  id: Integer(data[:operatorid])
                }
              }
            }
          }
        end
      end
    end
  end

  class Transaction
    def self.take(start = (Time.now - 24.hours), stop = Time.now, msisdn = nil, destination = nil, code = nil, qty = 5)
      reply = T2Airtime::API.api.transaction_list(start, stop, msisdn, destination, code)
      reply.success? ? serialize(reply.data, qty) : []
    end

    def self.serialize(data, qty = nil)
      return [] if data[:transaction_list].nil?
      ids = data[:transaction_list].split(',')
      ids.take(qty.nil? ? ids.count : qty).each.map { |id| show(id) }
    end

    def self.get(id)
      Rails.cache.fetch("transactions/#{id}", expires_in: 365.days) do # once we've got it, no need to refetch
        T2Airtime::API.api.transaction_info(id)
      end
    end    

    def self.show(id)
      transaction = get(id)
      transaction.success? ? serialize_one(transaction.data, transaction.headers[:date]) : {}
    end

    def self.serialize_one(data, ts = Time.zone.now.to_s)
      Rails.cache.fetch("transactions/#{data[:transactionid]}/serializer", expires_in: 365.hour) do
        {
          type: 'transactions',
          id: Integer(data[:transactionid]),
          attributes: {
            msisdn: data[:msisdn],
            destinationMsisdn: data[:destination_msisdn],
            transactionAuthenticationKey: data[:transaction_authentication_key],
            transactionErrorCode: Integer(data[:transaction_error_code]),
            transactionErrorTxt: data[:transaction_error_txt],
            referenceOperator: data[:reference_operator],
            actualProductSent: data[:actual_product_sent],
            sms: data[:sms],
            cid1: data[:cid1],
            cid2: data[:cid2],
            cid3: data[:cid3],
            date: data[:date],
            currency: data[:originating_currency],
            localCurrency: data[:destination_currency],
            pinBased: data[:pin_based],
            localInfoAmount: data[:local_info_amount],
            localInfoCurrency: data[:local_info_currency],
            localInfoValue: data[:local_info_value],
            errorCode: data[:error_code],
            errorTxt: data[:error_txt],
            countryId: Integer(data[:countryid]), 
            countryName: data[:country],
            countryAlpha3: T2Airtime::Country.alpha3(data[:country]),
            operatorId: Integer(data[:operatorid]),
            operatorName: data[:operator],
            operatorLogo: T2Airtime::Util.operator_logo_url(data[:operatorid]),  
            productName: "#{Money.new(Integer(data[:product_requested]) * 100, data[:destination_currency]).format}",
            productLocalCurrency: data[:destination_currency],
            productLocalCurrencySymbol: Money::Currency.new(data[:destination_currency]).symbol,
            productCurrency: Account.currency,
            productCurrencySymbol: Money::Currency.new(Account.currency).symbol,
            productLocalPrice: Float(data[:product_requested]),
            productRetailPrice: Float(data[:retail_price]),
            productWholesalePrice: Float(data[:wholesale_price]),          
            fetchedAt: T2Airtime::Util.format_time(ts)
          },
          relationships: {
            country: {
              data: {
                type: 'countries',
                id: Integer(data[:countryid])
              }
            },
            operator: {
              data: {
                type: 'operators',
                id: Integer(data[:operatorid])
              }
            },
            product: {
              data: {
                type: 'products',
                id: Integer(data[:product_requested])
              }
            }
          }
        }
      end
    end
  end
end
