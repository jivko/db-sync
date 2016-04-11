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
  let(:synchronizer) { Db::Sync.new }

  describe 'configuration' do
    it 'has a version number' do
      expect(Db::Sync::VERSION).not_to be nil
    end

    it 'has tables config' do
      expect(Db::Sync.config.tables).to contain_exactly('items')
    end

    it 'working tables' do
      expect(synchronizer.working_tables).to contain_exactly('items')
    end
  end

  describe 'sync up' do
    after(:each) do
      ActiveRecord::Base.connection.execute(truncate_sql)
    end

    it 'matches the records exactly' do
      synchronizer.insert_records(:items, original_records)
      expect(synchronizer).to receive(:insert_records).with('items', [], true)
      expect(synchronizer).to receive(:delete_records).with('items', [], true)
      expect(synchronizer).to receive(:update_records).with('items', [], true)
      synchronizer.sync_up
    end

    it 'makes changes when neccessary' do
      synchronizer.insert_records(:items, updated_records)
      synchronizer.sync_up
      res = synchronizer.table_model_records('items')
      expect(res).to eq(original_records)
    end

    it 'has log of operations' do
      synchronizer.sync_up
      expect(synchronizer.log.length).to eq(3)
    end
  end

  describe 'sync down' do
    after(:each) do
      ActiveRecord::Base.connection.execute(truncate_sql)
    end

    it 'matches the records exactly' do
      synchronizer.insert_records(:items, original_records)
      synchronizer.sync_down
      save_stream.rewind
      data = save_stream.read
      expect(data).to eq(load_data)
    end

    it 'do not match updated records' do
      synchronizer.insert_records(:items, updated_records)
      synchronizer.sync_down
      save_stream.rewind
      data = save_stream.read
      expect(data).to_not eq(load_data)
    end
  end
end
