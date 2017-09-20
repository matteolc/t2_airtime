[![Build Status](https://travis-ci.org/matteolc/t2_airtime.svg?branch=master)](https://travis-ci.org/matteolc/t2_airtime) 
[![Gem Version](https://badge.fury.io/rb/t2_airtime.svg)](https://badge.fury.io/rb/t2_airtime)
[![GitHub version](https://badge.fury.io/gh/matteolc%2Ft2_airtime.svg)](https://badge.fury.io/gh/matteolc%2Ft2_airtime)
[![Dependency Status](https://gemnasium.com/badges/github.com/matteolc/t2_airtime.svg)](https://gemnasium.com/github.com/matteolc/t2_airtime)
[![Code Climate](https://codeclimate.com/github/matteolc/t2_airtime.png)](https://codeclimate.com/github/matteolc/t2_airtime)

t2-airtime
==========

[T2-Airtime](https://matteolc.github.io/t2_airtime/) client, `t2_airtime`.

T2-Airtime is a Ruby gem providing a proxy cache and a REST API to [TransferTo](https://www.transfer-to.com/home) Airtime service.

## Installation

### Install as a Ruby gem

``` sh
gem install t2_airtime
```
### Setup Transfer-To credentials

1. Make sure you are a registered user of [Transfer-To](https://www.transfer-to.com/home).
2. Enable Two Factor Authentication (2FA) in your [Transfer-To Shop](https://shop.transferto.com) Security Center section
2. Retrieve API key (token) created by Transfer-To Shop.
3. Export your secrets as an environment variables:

```sh
export T2_SHOP_USER=<your_username>
export T2_AIRTIME_KEY=<your_token>
```

4. Export the host allowed to access the API (CORS):
```sh
export CORS_ORIGIN=<your_frontend_address>
```

5. Export your API secrets:

```sh
export API_KEY=<t2_airtime_key>
export API_TOKEN=<t2_airtime_token>
```


### Using Docker

1. Download image:

```
docker pull voxbox/t2_airtime
```

2. Export your secrets in env (see previous step)

3. Run:

```sh
docker run -d \
  --name t2_airtime \
  -p 3000:3000 \
  -e T2_SHOP_USER \
  -e T2_AIRTIME_KEY \
  -e API_KEY \
  -e API_TOKEN \
  -e CORS_ORIGIN \
  voxbox/t2_airtime
```

## Development

1.  If needed, install bundler:

    ```sh
    $ gem install bundler
    ```

2.  Clone the repo:

    ```sh
    $ git clone git@github.com:matteolc/t2_airtime.git
    $ cd t2_airtime
    ```

3.  Install dependencies:

    ```sh
    $ bundle install
    ```

## Test

Inside the `t2_airtime` repository directory run:

```sh
$ bundle exec rspec
```

To start a development server:

```sh
$ cd spec/dummy
$ puma -C config/puma.rb
```


## License

Copyright 2015-17 (c) Matteo La Cognata

Released under MIT license.
See [LICENSE](https://raw.githubusercontent.com/apiaryio/apiary-client/master/LICENSE) file for further details.