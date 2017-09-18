[![Build Status](https://travis-ci.org/matteolc/t2_airtime.svg?branch=master)](https://travis-ci.org/matteolc/t2_airtime) 
[![Gem Version](https://badge.fury.io/rb/t2_airtime.svg)](https://badge.fury.io/rb/t2_airtime)
[![GitHub version](https://badge.fury.io/gh/matteolc%2Ft2_airtime.svg)](https://badge.fury.io/gh/matteolc%2Ft2_airtime)
[![Dependency Status](https://gemnasium.com/badges/github.com/matteolc/t2_airtime.svg)](https://gemnasium.com/github.com/matteolc/t2_airtime)

t2-airtime
==========

[T2-Airtime](https://matteolc.github.io/t2_airtime/) client, `t2_airtime`.

T2-Airtime is a Ruby gem providing a proxy cache and a REST API to [TransferTo](https://www.transfer-to.com/home) Airtime service.

## Installation

### Install as a Ruby gem

``` sh
gem install t2_airtime
```

### Using Docker - alternative if you don't install ruby or installation not work for you

Download image:

```
docker pull voxbox/t2_airtime
```
Run `docker run voxbox/t2_airtime`

Build from source code:

```
docker build -t "voxbox/t2_airtime" .
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


## License

Copyright 2015-17 (c) Matteo La Cognata

Released under MIT license.
See [LICENSE](https://raw.githubusercontent.com/apiaryio/apiary-client/master/LICENSE) file for further details.