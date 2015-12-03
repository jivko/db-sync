require 'db/sync/version'

module Db
  module Sync
    # Your code goes here...
    class Railtie < Rails::Railtie
      rake_tasks do
        load File.expand_path('../../tasks/db-sync.rake', __FILE__)
      end
    end
  end
end
