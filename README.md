# TransferTo Airtime API

[TransferTo](https://www.transfer-to.com/home) helps businesses offer airtime top-ups, goods and services, and mobile money around the world in real time.
TransferTo Airtime API enables developers to integrate TransferTo Top-up service into their system.

This gem is a convenience wrapper around the Airtime API. Requirement is that Two Factor Authentication (2FA) is enabled in your [TransferTo Shop](https://shop.transferto.com) Security Center section.


## Usage

Create a new rails application:

    rails new t2_airtime

Add this line to your application's Gemfile:

```ruby
gem 't2_airtime'
```   

And then execute:

    $ bundle 

Create a `.env` file with the required information:

    T2_SHOP_USER=
    T2_AIRTIME_KEY=

Start the server: `bundle exec puma -C config/puma.rb`

### Routes

The following routes are mada available to your application when you mount the API engine in `config/routes.rb`:

```ruby
mount T2Airtime::Engine => '/t2_airtime'
```

* `/t2_airtime/account` [Account information](#account_info)
* `/t2_airtime/countries` [List of all countries offered](#country_list)
* `/t2_airtime/countries/<country_id>/operators` [List of all operators available for a certain country](#operator_list)
* `/t2_airtime/countries/<country_id>/operators/<operator_id>/products` [List of all products available for a certain operator](#product_list)
* `/t2_airtime/transactions` [List all transactions](#transaction_list)
* `/t2_airtime/transactions/<id>` [Show a transaction](#transaction_show)
    
### API Object

You can access the Airtime API in Ruby as:

```ruby
api = T2Airtime::API.api
```

The following methods are available to the `api` object:

* `ping` [Test the connection to the Airtime API](#ping)
* `account_info` [Information regarding your TransferTo account](#account_info)
* `country_list` [Retrieve available countries](#country_list)
* `operator_list` [Retrieve all operators available for a certain country](#operator_list)
* `product_list` [Retrieve all products available for a certain operator](#product_list)
* `transaction_list` [Retrieve the list of transactions performed within a date range](#transaction_list)
* `transaction_info` [Retrieve available information on a specific transaction](#transaction_info)
* `topup` Recharge a destination number with a specified product.
* `msisdn_info` Retrieve various information of a specific MSISDN as well as the list of all products configured for your specific account and the destination operator of the MSISDN.
* `reserve_id` Reserve a transaction ID in the system. Maybe used in a topup operation.
* `get_id_from_key` Retrieve the ID of a transaction previously performed based on the key used in the request at that time.

Each method returns an object with the following properties:

* `success?` `true` if the request was successful.
* `status` The HTTP status of the reply. `200` indicates a successful request.
* `error_code` The error code of the request. `0` indicates a successful request.
* `error_message` The error message of the request. `Transaction successful` indicates a successful request.
* `url` The full URL of the request.
* `information` The response body as a hash.
* `auth_key` The authorization key used in the request.
* `headers` The HTTP Headers of the reply.
* `raw` The raw body of the reply.

<a name="ping"></a>
#### Ping

This method can be used for keep-alive. To test the connection with the API:

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.ping
irb(main)> response.success?
=> true
{{</ highlight >}} 

<a name="account_info"></a>
#### Account Information

The `account_info` method retrieves the various information regarding your TransferTo account. 
To format the response as JSON-API you can call `T2Airtime::Account.serialize(data)`.

From a Rails console (or Ruby file):

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.account_info
irb(main)> account= T2Airtime::Account.serialize(response.data)
{{</ highlight >}} 

The serializer returns the following JSON representation of your account:

{{< highlight ruby >}}
{
    "type": "accounts",
    # Account login name
    "id": ACCOUNT_ID,
    "attributes": {
        # Account type: "Master" (main account) or "Retailer" (subaccount)
        "type": ACCOUNT_TYPE 
        # Account login name
        "name": ACCOUNT_NAME,
        # Account currency (USD, GBP, EUR, etc…)
        "currency": ACCOUNT_CURRENCY,
        # For main account: returns the account’s remaining balance.
        # For sub-account: returns the account’s remaining limit balance
        # of the day if a daily limit is fixed. Else, returns the account
        # remaining balance
        "balance": ACCOUNT_BALANCE,
        # For main account: returns the total remaining balance (sum 
        # of all sub-accounts and current master).
        # For sub-account: 
        # 1. If balance is shared and daily limit is fixed: returns the fixed daily limit amount 
        # 2. If balance is shared but daily limit is not fixed: returns "No Limit"
        # 3. Else if balance is not shared: returns the remaining balance        
        "wallet": ACCOUNT_WALLET,
        # The time at which the information was fetched. 
        # Can be used for caching purposes.
        "fetched-at": TIMESTAMP
    }
}
{{</ highlight >}}

From a browser:
[http://localhost:3000/account](/)

![JSON response](/img/account_json.png) 

<a name="country_list"></a>
#### Country List

The `country_list` method retrieves the countries offered in your TransferTo price list. 
To format the response as JSON-API you can call `T2Airtime::Country.serialize(data)`.

From a Rails console (or Ruby file):

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.country_list
irb(main)> countries= T2Airtime::Country.serialize(response.data)
{{</ highlight >}} 

The serializer returns the following JSON representation of a country:

{{< highlight ruby >}}
{
    "type": "countries",
    # Unique Airtime ID for the country
    "id": COUNTRY_ID,
    "attributes": {
        # The country name
        "name": COUNTRY_NAME, 
        # The ISO 3166-1 country alpha-3, https://it.wikipedia.org/wiki/ISO_3166-1_alpha-3
        # Can be used for unique country identification.
        "alpha3": COUNTRY_ALPHA3,
        # The time at which the country was fetched. 
        # Can be used for caching purposes.
        "fetched-at": TIMESTAMP
    },
    "relationships": {
        "operators": { "links": { "related": "/countries/COUNTRY_ID/operators" } }
    }
}
{{</ highlight >}} 

The `relationships` section of the response provides a link you can use to navigate the country operators.

From a browser:
[http://localhost:3000/countries](/)

![JSON response](/img/country_list_json.png)

<a name="operator_list"></a>
#### Operator List

The `operator_list` method retrieves the operators available for a certain country. 
To format the response as JSON-API you can call `T2Airtime::Operator.serialize(data)`.

From a Rails console (or Ruby file):

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.operator_list countries.shuffle.first["id"]
irb(main)> operators= T2Airtime::Operator.serialize(response.data)
{{</ highlight >}} 

The serializer returns the following JSON representation of an operator:

{{< highlight ruby >}}
{
    "type": "operators",
    # Unique Airtime ID for the operator
    "id": OPERATOR_ID,
    "attributes": {
        # The operator name
        "name": OPERATOR_NAME, 
        # The time at which the operator was fetched. 
        # Can be used for caching purposes.        
        "fetched-at": TIMESTAMP
    },
    "links": {
        # The URL at which you can retrieve the operator's logo
        logo: OPERATOR_LOGO_URL
    },
    "relationships": {
        "country": { "data": { "type": "countries", "id": COUNTRY_ID } },
        "products": { "links": { "related": "/countries/COUNTRY_ID/operators/OPERATOR_ID/products" } }              
    },
    "included": [
        {
            "type": "countries",
            "id": COUNTRY_ID,
            "attributes": {
                "name": COUNTRY_NAME,             
                "alpha3": COUNTRY_ALPHA3
            }                
        }
    ] 
}
{{</ highlight >}}             

* The `relationships` section of the response provides a link you can use to navigate the operator products.
* The `included` section of the response provides all the information regarding the operator's country.

From a browser:
[http://localhost:3000/countries/COUNTRY_ID/operators](/)

![JSON response](/img/operator_list_json.png)

<a name="product_list"></a>
#### Product List

The `product_list` method retrieves the products available for a certain operator. 
To format the response as JSON-API you can call `T2Airtime::Product.serialize(data)`.

From a Rails console (or Ruby file):

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.product_list operators.shuffle.first["id"]
irb(main)> products= T2Airtime::Product.serialize(response.data)
{{</ highlight >}} 

The serializer returns the following JSON representation of a product:

{{< highlight ruby >}}
{
    "type": "products",
    # Airtime ID for the product. Attention! It is only unique within
    # the scope of the operator
    "id": PRODUCT_ID, 
    "attributes": {
        # The product name, or face value for display, es. 5EUR
        "name": PRODUCT_NAME, 
        # Currency of the destination country
        "currency": PRODUCT_CURRENCY,
        # The face value of the product (same as id)
        "local-price": PRODUCT_LOCAL_PRICE,
        # The retail price of the product
        "retail-price": PRODUCT_RETAIL_PRICE,
        # The wholesale price  (also known as your cost) of the product
        "wholesale-price": PRODUCT_WHOLESALE_PRICE,  
        # The time at which the operator was fetched. 
        # Can be used for caching purposes.                     
        "fetched-at": TIMESTAMP
    },
    "relationships": {
        "country": { "data": { "type": "countries", "id": COUNTRY_ID } },
        "operator": { "data": { "type": "operators", "id": OPERATOR_ID } }
    },
    "included": [
        {
            "type": "countries",
            "id": COUNTRY_ID,
            "attributes": {
                "name": COUNTRY_NAME,
                "alpha3": COUNTRY_ALPHA3
            }                
        },
        {
            "type": "operators",
            "id": OPERATOR_ID,
            "attributes": { "name": OPERATOR_NAME },
            "links": { "logo": OPERATOR_LOGO_URL }              
        }
    ]
    }
}
{{</ highlight >}}             

* The `relationships` section of the response provides a link you can use to navigate the product `included` relationships.
* The `included` section of the response provides all the information regarding the product's country and operator.

From a browser:
[http://localhost:3000/countries/COUNTRY_ID/operators/OPERATOR_ID/products](/)

![JSON response](/img/product_list_json.png)

<a name="transaction_list"></a>
#### Transaction List

The `transaction_list` method retrieves all transaction within the specified time-range. 
To format the response as JSON-API you can call `T2Airtime::Transaction.serialize(data)`.

From a Rails console (or Ruby file):

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.transaction_list
irb(main)> transactions= T2Airtime::Transaction.serialize(response.data)
{{</ highlight >}} 

From a browser:
[http://localhost:3000/transactions](/)

![JSON response](/img/transaction_list_json.png)


<a name="transaction_info"></a>
#### Transaction Information

The `transaction_info` method retrieves information regarding a certain transaction. 
To format the response as JSON-API you can call `T2Airtime::Transaction.serialize_one(data)`.

From a Rails console (or Ruby file):

{{< highlight ruby >}}
irb(main)> response= T2Airtime::API.api.transaction_info
irb(main)> transactions= T2Airtime::Transaction.serialize_one(response.data)
{{</ highlight >}}

The serializer returns the following JSON representation of a transaction:

{{< highlight ruby >}}
{
    type: "transactions",
    # Unique Airtime ID for the transaction
    id: TRANSACTION_ID,
    attributes: {
        # The international phone number or name of 
        # the user (sender) requesting to credit a phone 
        # number
        "msisdn": TRANSACTION_MSISDN,
        # Destination MSISDN (usually recipient phone number)
        "destination-msisdn": TRANSACTION_DESTINATION_MSISDN,
        # Authentication key used during the transaction
        "transaction-authentication-key": TRANSACTION_AUTHENTICATION_KEY,
        # Error code for the transaction
        "transaction-error-code": TRANSACTION_ERROR_CODE,
        # Description of the error code for the transaction
        "transaction-error-txt": TRANSACTION_ERROR_TEXT,
        # Reference of the operator (returned only if available)
        "reference-operator": TRANSACTION_REFERENCE_OPERATOR,
        # Returns the value requested to the operator 
        # (equals to product_requested in case of successful
        # transaction). It equals to 0 when Top-up 
        # failed.
        "actual-product-sent": TRANSACTION_PRODUCT_SENT,
        # Recipient SMS
        # Returns the custom message appended to the 
        # default notification SMS sent to the recipient
        "sms": TRANSACTION_SMS,
        # Value of the customized field cid1 sent in the Top-up request
        "cid1": TRANSACTION_CID1,
        # Value of the customized field cid2 sent in the Top-up request
        "cid2": TRANSACTION_CID2,
        # Value of the customized field cid3 sent in the Top-up request
        "cid3": TRANSACTION_CID3,
        # Date of the transaction (GMT)
        "date": TRANSACTION_DATE,
        # Currency of the account from which the transaction is requested
        "originating-currency": TRANSACTION_ORIGINATING_CURRENCY,
        # Currency of the destination country
        "destination-currency": TRANSACTION_DESTINATION_CURRENCY,
        # Type of product returned ("Yes", default "No" if not set)
        "pin-based": TRANSACTION_PIN_BASED,
        # Final amount received by recipient. Indicative value only
        "local-info-amount": TRANSACTION_LOCAL_INFO_AMOUNT,
        # Local currency in destination
        "local-info-currency": TRANSACTION_LOCAL_INFO_CURRENCY,
        # Value of the transaction before tax and service 
        # fee in local currency.
        "local-info-amount": TRANSACTION_LOCAL_INFO_AMOUNT,
        # The time at which the transaction was fetched. 
        # Can be used for caching purposes.         
        "fetched-at": TIMESTAMP
    },
    relationships: {
        country: { data: { type: "countries", id: COUNTRY_ID } },
        operator: { data: { type: "operators", id: OPERATOR_ID } },
        product: { data: { type: "products", id: PRODUCT_ID } }
    },
    included: [
        {
            type: "countries",
            id: COUNTRY_ID,
            attributes: {
                "name": COUNTRY_NAME,
                "alpha3": COUNTRY_ALPHA3
            }                
        },
        {
            type: "operators",
            id: OPERATOR_ID,
            attributes: { "name": OPERATOR_NAME },
            links: { logo: OPERATOR_LOGO_URL }               
        },
        {
            type: "products",
            id: PRODUCT_ID,
            attributes: {
                "name": PRODUCT_NAME,
                "currency": PRODUCT_CURRENCY,
                "wholesale-price": PRODUCT_WHOLESALE_PRICE,
                "retail-price": PRODUCT_RETAIL_PRICE,
                "local-price": PRODUCT_LOCAL_PRICE
            }              
        }
    ]
}
{{</ highlight >}}             

* The `relationships` section of the response provides a link you can use to navigate the product `included` relationships.
* The `included` section of the response provides all the information regarding the product's country and operator.

From a browser:
[http://localhost:3000/transactions/TRANSACTION_ID](/)

![JSON response](/img/transaction_list_json.png)  

## Testing

Clone this repository and export your secrets:

    $> export T2_SHOP_USER=
    $> export T2_AIRTIME_KEY=

Execute:

    rake

To execute the test application:

    cd spec/dummy

Start the server: `puma -C config/puma.rb`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matteolc/t2_airtime.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).