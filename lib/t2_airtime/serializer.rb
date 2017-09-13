module T2Airtime

  class Account

    def self.info
        reply = T2Airtime::API.api.account_info
        reply.success? ? serialize(reply.data, reply.headers[:date]) : []
    end

    def self.serialize(data, ts="#{Time.zone.now}")
      {
        type: "accounts",
        id: T2Airtime::API.api.user,
        attributes: {
          "type": data[:type],
          "name": data[:name],
          "currency": data[:currency],
          "balance": Float(data[:balance]),          
          "wallet": Float(data[:wallet]),
          "fetched-at": T2Airtime::Util.format_time(ts)
        }
      }.as_json
    end

  end  

  class Country

    def self.take(qty=5)
        reply = T2Airtime::API.api.country_list
        reply.success? ? serialize(reply.data, reply.headers[:date], qty) : []
    end

    def self.serialize(data, ts="#{Time.zone.now}", qty=nil)
        return [] if data[:countryid].nil?
        names = data[:country].split(",") 
        ids = data[:countryid].split(",")
        ids.take(qty.nil? ? ids.count : qty).each_with_index.map{|id, n| {
          type: "countries",
          id: Integer(id),
          attributes: {
            "name": names[n], 
            "alpha3": alpha3(names[n]),
            "fetched-at": T2Airtime::Util.format_time(ts)
          },
          relationships: {
            operators: {
              links: {
                related: "/countries/#{id}/operators"
              }
            }
          }
        }}.as_json
    end

    def self.normalize(name)
       name.starts_with?("St") ? name.gsub("St", "Saint") : name
    end

    def self.alpha3(name)
      alpha3 = ISO3166::Country.find_country_by_name(name).try(:alpha3)
      unless alpha3           
        alpha3 = case name
        when 'Saint Vincent Grenadines'
          'VCT';
        when 'Kosovo'
          'UNK'
        when 'Netherlands Antilles'
          'ANT'
        when 'Serbia and Montenegro'
          'SCG'
        end        
        register_alpha3(alpha3, name) if %w(VCT UNK ANT SCG).include?(alpha3)
      end
      alpha3 || "XXX"
    end  

    def self.register_alpha3(alpha3, name)
        ISO3166::Data.register(
          alpha2: 'XX',
          alpha3: alpha3,
          name: name
        ) 
    end

  end

  class Operator

    def self.take(country_qty=1, qty=5)
        countries = T2Airtime::Country.take(country_qty).shuffle
        unless countries.empty?
          countries.flat_map{|country| (
            reply = T2Airtime::API.api.operator_list(country["id"])
            reply.success? ? serialize(reply.data, reply.headers[:date], qty) : []
          )}        
        end
    end    

    def self.serialize(data, ts="#{Time.zone.now}", qty=nil)
         return [] if data[:operator].nil?
         names = data[:operator].split(",") 
         ids = data[:operatorid].split(",")
         ids.take(qty.nil? ? ids.count : qty).each_with_index.map{|id, n| {
            type: "operators",
            id: Integer(id),
            attributes: {
              "name": names[n], 
              "fetched-at": T2Airtime::Util.format_time(ts)
            },
            links: {
              logo: T2Airtime::Util.operator_logo_url(id)
            },
            relationships: {
              country: {
                data: { 
                  type: "countries",
                  id: Integer(data[:countryid])
                }
              },
              products: {
                links: {
                  related: "/countries/#{data[:countryid]}/operators/#{id}/products"
                }
              }              
            },
            included: [
              {
                  type: "countries",
                  id: Integer(data[:countryid]),
                  attributes: {
                    "name": data[:country],
                    "alpha3": T2Airtime::Country.alpha3(data[:country])
                  }                
              }
            ]            
         }}.as_json
    end
    
  end

  class Product

    def self.take(operator_qty=1, qty=5)
        operators = T2Airtime::Operator.take(operator_qty).shuffle
        unless operators.empty?
          operators.flat_map{|operator| (
            reply = T2Airtime::API.api.product_list(operator["id"])
            reply.success? ? serialize(reply.data, reply.headers[:date], qty) : []
          )}        
        end         
    end

    def self.serialize(data, ts="#{Time.zone.now}", qty=nil)
         return [] if data[:product_list].nil?          
         ids = data[:product_list].split(",")
         retail_prices = data[:retail_price_list].split(",") 
         wholesale_prices = data[:wholesale_price_list].split(",")         
         ids.take(qty.nil? ? ids.count : qty).each_with_index.map{|id, n| {
           type: "products",
           id: Integer(id), 
           attributes: {
            "name": "#{id}#{data[:destination_currency]}", 
            "currency": data[:destination_currency],
            "local-price": Float(id),
            "retail-price": Float(retail_prices[n]),
            "wholesale-price": Float(wholesale_prices[n]),           
            "fetched-at": T2Airtime::Util.format_time(ts)
           },
            relationships: {
              country: {
                data: { 
                  type: "countries",
                  id: Integer(data[:countryid])
                }
              },
              operator: {
                data: { 
                  type: "operators",
                  id: Integer(data[:operatorid])
                }
              }
            },
            included: [
              {
                  type: "countries",
                  id: Integer(data[:countryid]),
                  attributes: {
                    "name": data[:country],
                    "alpha3": T2Airtime::Country.alpha3(data[:country])
                  }                
              },
              {
                  type: "operators",
                  id: Integer(data[:operatorid]),
                  attributes: {
                    "name": data[:operator]
                  },
                  links: {
                    logo: T2Airtime::Util.operator_logo_url(data[:operatorid])
                  }              
              }
            ]
         }}.as_json
    end

  end  

  class Transaction

    def self.take(start=(Time.now-24.hours), stop=Time.now, msisdn=nil, destination=nil, code=nil, qty=5)
        reply = T2Airtime::API.api.transaction_list(start, stop, msisdn, destination, code)
        reply.success? ? serialize(reply.data, qty) : []
    end
      
    def self.serialize(data, qty=nil)
      return [] if data[:transaction_list].nil?
      ids = data[:transaction_list].split(",")
      ids.take(qty.nil? ? ids.count : qty).each.map{ |id| show(id) }
    end


    def self.show(id)
        reply = T2Airtime::API.api.transaction_info(id)
        reply.success? ? serialize_one(reply.data, reply.headers[:date]) : {}
    end

    def self.serialize_one(data, ts="#{Time.zone.now}")
      {
        type: "transactions",
        id: Integer(data[:transactionid]),
        attributes: {
          "msisdn": data[:msisdn],
          "destination-msisdn": data[:destination_msisdn],
          "transaction-authentication-key": data[:transaction_authentication_key],
          "transaction-error-code": Integer(data[:transaction_error_code]),
          "transaction-error-txt": data[:transaction_error_txt],
          "reference-operator": data[:reference_operator],
          "actual-product-sent": data[:actual_product_sent],
          "sms": data[:sms],
          "cid1": data[:cid1],
          "cid2": data[:cid2],
          "cid3": data[:cid3],
          "date": data[:date],
          "originating-currency": data[:originating_currency],
          "destination-currency": data[:destination_currency],
          "pin-based": data[:pin_based],
          "local-info-amount": data[:local_info_amount],
          "local-info-currency": data[:local_info_currency],
          "local-info-value": data[:local_info_value],
          "error-code": data[:error_code],
          "error-txt": data[:error_txt],
          "fetched-at": T2Airtime::Util.format_time(ts)
        },
        relationships: {
          country: {
            data: { 
              type: "countries",
              id: Integer(data[:countryid])
            }
          },
          operator: {
            data: { 
              type: "operators",
              id: Integer(data[:operatorid])
            }
          },
          product: {
            data: { 
              type: "products",
              id: Integer(data[:product_requested])
            }
          }
        },
        included: [
          {
              type: "countries",
              id: Integer(data[:countryid]),
              attributes: {
                "name": data[:country],
                "alpha3": T2Airtime::Country.alpha3(data[:country])
              }                
          },
          {
              type: "operators",
              id: Integer(data[:operatorid]),
              attributes: {
                "name": data[:operator]
              },
              links: {
                logo: T2Airtime::Util.operator_logo_url(data[:operatorid])
              }               
          },
          {
              type: "products",
              id: Integer(data[:product_requested]),
              attributes: {
                "name": "#{data[:product_requested]}#{data[:destination_currency]}",
                "currency": data[:destination_currency],
                "wholesale-price": data[:wholesale_price],
                "retail-price": data[:retail_price],
                "local-price": Float(data[:product_requested])
              }              
          }
        ]
      }.as_json
    end


  end

  
end
