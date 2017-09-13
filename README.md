# TransferTo Airtime API

[TransferTo](https://www.transfer-to.com/home) helps businesses offer airtime top-ups, goods and services, and mobile money around the world in real time.
TransferTo Airtime API enables developers to integrate TransferTo Top-up service into their system.

This gem is a convenience wrapper around the Airtime API. Requirement is that Two Factor Authentication (2FA) is enabled in your [TransferTo Shop](https://shop.transferto.com) Security Center section.


## Usage

Create a new rails application:

    rails new airtime

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
mount T2Airtime::Engine => '/airtime'
```

    http://localhost:3000/airtime/transactions
    http://localhost:3000/airtime/transactions/<id>
    http://localhost:3000/airtime/countries
    http://localhost:3000/airtime/<country_id>/operators
    http://localhost:3000/airtime/<operator_id>/products
    
### Helpers

Main API helper:

```ruby
api = T2Airtime::API.api
```

[TBC]   

## Testing

Clone this repository and export your secrets:

    $> export T2_SHOP_USER=
    $> export T2_AIRTIME_KEY=

Execute:

    rake
    
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/t2_airtime. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the T2Airtime project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/t2_airtime/blob/master/CODE_OF_CONDUCT.md).
