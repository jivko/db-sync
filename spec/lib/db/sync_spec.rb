require 'spec_helper'

describe Db::Sync do
  let(:load_data) { File.read('spec/files/items.yml') }
  let(:save_stream) { StringIO.new }
  before(:each) do
    allow(File).to receive(:open).with('./db/data/items.yml', 'w').and_yield(save_stream)
    allow(File).to receive(:read).with('./db/data/items.yml').and_return(load_data)
    Db::Sync.configure do |config|
      config.tables = ['items']
    end
  end
  let(:arbitrary_date) { Time.new(2016, 1, 1, 13, 0, 0, '+00:00') }
  let(:truncate_sql) { 'DELETE FROM items' }
  let(:original_records) do
    [
      { id: 3, title: 't1', body: 'b1', number: 1, available: true, created_at: arbitrary_date, updated_at: arbitrary_date },
      { id: 4, title: 't2', body: 'b2', number: 2, available: true, created_at: arbitrary_date, updated_at: arbitrary_date },
      { id: 5, title: 't3', body: 'b3', number: 3, available: false, created_at: arbitrary_date, updated_at: arbitrary_date }
    ].map(&:stringify_keys)
  end
  let(:updated_records) do
    [
      { id: 3, title: 't1', body: 'b1', number: 1, available: true, created_at: arbitrary_date, updated_at: arbitrary_date },
      { id: 4, title: 't3', body: 'b2', number: 2, available: true, created_at: arbitrary_date, updated_at: arbitrary_date },
      { id: 6, title: 't3', body: 'b3', number: 3, available: false, created_at: arbitrary_date, updated_at: arbitrary_date }
    ].map(&:stringify_keys)
  end

  describe 'configuration' do
    it 'has a version number' do
      expect(Db::Sync::VERSION).not_to be nil
    end

    it 'has tables config' do
      expect(Db::Sync.config.tables).to contain_exactly('items')
    end

    it 'working tables' do
      expect(Db::Sync.working_tables).to contain_exactly('items')
    end
  end

  describe 'sync up' do
    after(:each) do
      ActiveRecord::Base.connection.execute(truncate_sql)
    end

    it 'matches the records exactly' do
      Db::Sync.insert_records(:items, original_records)
      expect(Db::Sync).to receive(:insert_records).with('items', [])
      expect(Db::Sync).to receive(:delete_records).with('items', [])
      expect(Db::Sync).to receive(:update_records).with('items', [])
      Db::Sync.sync_up
    end

    it 'makes changes when neccessary' do
      Db::Sync.insert_records(:items, updated_records)
      Db::Sync.sync_up
      res = Db::Sync.table_model_records('items')
      expect(res).to eq(original_records)
    end
  end

  describe 'sync down' do
    after(:each) do
      ActiveRecord::Base.connection.execute(truncate_sql)
    end

    it 'matches the records exactly' do
      Db::Sync.insert_records(:items, original_records)
      Db::Sync.sync_down
      save_stream.rewind
      data = save_stream.read
      expect(data).to eq(load_data)
    end

    it 'do not match updated records' do
      Db::Sync.insert_records(:items, updated_records)
      Db::Sync.sync_down
      save_stream.rewind
      data = save_stream.read
      expect(data).to_not eq(load_data)
    end
  end
end
