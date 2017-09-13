module T2Airtime
  class Engine < ::Rails::Engine
    isolate_namespace T2Airtime

    config.generators do |g|
      g.api_only = true
      g.test_framework :rspec
    end    
    
  end
end