$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'db/sync'
require 'active_record'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
load File.dirname(__FILE__) + '/schema.rb'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
