require 'dotenv'
Dotenv.load
require "faraday"
require "net/http"
require "countries"

require "t2_airtime/version"
require "t2_airtime/engine"
require "t2_airtime/url"
require "t2_airtime/errors"
require "t2_airtime/request"
require "t2_airtime/reply"
require "t2_airtime/base"
require "t2_airtime/api"
require "t2_airtime/util"
require "t2_airtime/serializer"

module T2Airtime; end

