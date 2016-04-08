require 'db/sync/version'
require 'db/sync/diff'
require 'rails'
require 'active_record'
require 'db/sync/model'

module Db
  # Databse Sync
  class Sync
    include ActiveSupport::Configurable

    def self.sync_up
      # TODO: change to row by row loading
      working_tables.each do |table|
        table_model = data_model(table)
        fail 'Tables without id are not supported!' unless table_model.include_id?

        data = File.read(table_filename(table))
        all_records = YAML.load(data)
        current_records = table_model.records.map(&:attributes)

        diff = Db::Sync::Diff.new(current_records, all_records, table_model.pkey)
        insert_records(table, diff.inserts)
        delete_records(table, diff.deletes)
        update_records(table, diff.updates)
      end
    end

    def self.insert_records(table, inserts)
      inserts.each do |record|
        insert_manager = Arel::InsertManager.new(ActiveRecord::Base)
        arel_model = Arel::Table.new(table)
        insert_data = record.map do |key, value|
          [arel_model[key], value]
        end
        insert_manager.insert(insert_data)
        # print "#{insert_manager.to_sql}\n"
        ActiveRecord::Base.connection.execute(insert_manager.to_sql)
      end
    end

    def self.delete_records(table, deletes)
      arel_model = Arel::Table.new(table)

      deletes.each do |delete_params|
        delete_manager = Arel::DeleteManager.new(ActiveRecord::Base)
        delete_manager.from(arel_model)
        delete_data = delete_params.map do |key, value|
          [arel_model[key].eq(value)]
        end
        delete_manager.where(delete_data)
        # print "#{delete_manager.to_sql}\n"
        ActiveRecord::Base.connection.execute(delete_manager.to_sql)
      end
    end

    def self.update_records(table, updates)
      arel_model = Arel::Table.new(table)

      updates.each do |update|
        update_manager = Arel::UpdateManager.new(ActiveRecord::Base)
        update_key = update[:key].map do |key, value|
          [arel_model[key].eq(value)]
        end
        update_changes = update[:changes].map do |key, value|
          [arel_model[key], value]
        end
        update_manager.table(arel_model).where(update_key).set(update_changes)
        # print "#{update_manager.to_sql}\n"
        ActiveRecord::Base.connection.execute(update_manager.to_sql)
      end
    end

    def self.sync_down
      # TODO: change to row by row saving
      working_tables.each do |table|
        File.open(table_filename(table), 'w') do |f|
          current_records = table_model_records(table)
          f << current_records.to_yaml
        end
      end
    end

    def self.table_model_records(table)
      # TODO: Some kind of paging
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
      result = Class.new(Db::Sync::Model)
      result.table_name = table
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
