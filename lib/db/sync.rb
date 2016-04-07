require 'db/sync/version'
require 'db/sync/diff'
require 'rails'
require 'active_record'

module Db
  # Databse Sync
  class Sync
    include ActiveSupport::Configurable

    def self.sync_up
      # TODO: change to row by row loading
      print "up\n"
      working_tables.each do |table|
        table_model = data_model(table)
        print "Loading table [#{table}]\n"
        fail 'Tables without id are not supported!' unless table_model.include_id?

        table_changes = { inserts: [], updates: [], deletes: [] }

        data = File.read(table_filename(table))
        all_records = YAML.load(data)
        current_records = table_model.records.map(&:attributes)

        diff = Db::Sync::Diff.new(current_records, all_records, table_model.pkey)
        print "\n", "inserts\n", diff.inserts, "\n"
        print "deletes\n", diff.deletes, "\n"
        print "updates\n", diff.updates, "\n"
      end
    end

    def self.sync_down
      # TODO: change to row by row saving
      print "down\n"
      working_tables.each do |table|
        print "Saving table [#{table}]\n"
        File.open(table_filename(table), 'w') do |f|
          current_records = table_model_records(table)
          f << current_records.to_yaml
        end
      end
    end

    def self.table_model_records(table)
      table_model = data_model(table)
      table_model.records.map(&:attributes)
    end

    def self.working_tables
      config.tables || all_tables
    end

    def self.all_tables
      ActiveRecord::Base.connection.tables.reject do |table|
        %w(schema_info, schema_migrations).include?(table)
      end
    end

    def self.table_filename(table)
      # TODO: change data with custom dir
      File.join(Rails.root || '.', 'db', 'data', "#{table}.yml")
    end

    def self.configure
      yield(config)
    end

    def self.data_model(table)
      result = Class.new(ActiveRecord::Base) do
        def self.include_id?
          attribute_names.include?('id')
        end

        def self.pkey
          if include_id?
            ['id']
          else
            attribute_names.sort
          end
        end

        def self.records
          order(pkey)
        end
      end

      result.table_name = table

      result.send(:define_method, :unique_data) do
        attributes.slice(*self.class.pkey)
      end

      result.send(:define_method, :compare_unique_data) do |other|
        self.class.pkey.each do |key|
          attributes[key] <=> other[key]
        end
      end

      result.primary_key = nil unless result.include_id?

      result
    end

    # Railtie needed, so that rake tasks are appended, when used as a gem
    class Railtie < Rails::Railtie
      rake_tasks do
        load File.expand_path('../../tasks/db-sync.rake', __FILE__)
      end
    end
  end
end
