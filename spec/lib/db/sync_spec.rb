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
  let(:some_records_insert_sql) do
    insert_sql = 'INSERT INTO items (id, title, body, number, created_at, updated_at) VALUES '
    insert_sql += "(3, 't1', 'b1', 1, '13:00:00 01-01-2016', '13:00:00 01-01-2016'),"
    insert_sql += "(4, 't2', 'b2', 2, '13:00:00 01-01-2016', '13:00:00 01-01-2016'),"
    insert_sql += "(5, 't3', 'b3', 3, '13:00:00 01-01-2016', '13:00:00 01-01-2016')"
    insert_sql
  end
  let(:some_records) do
    [
      { 'id' => 3, 'title' => 't1', 'body' => 'b1', 'number' => 1, 'created_at' => '13:00:00 01-01-2016', 'updated_at' => '13:00:00 01-01-2016' },
      { 'id' => 4, 'title' => 't2', 'body' => 'b2', 'number' => 2, 'created_at' => '13:00:00 01-01-2016', 'updated_at' => '13:00:00 01-01-2016' },
      { 'id' => 5, 'title' => 't3', 'body' => 'b3', 'number' => 3, 'created_at' => '13:00:00 01-01-2016', 'updated_at' => '13:00:00 01-01-2016' }
    ]
  end
  let(:updated_records_insert_sql) do
    insert_sql = 'INSERT INTO items (id, title, body, number, created_at, updated_at) VALUES '
    insert_sql += "(3, 't1', 'b1', 1, '13:00:00 01-01-2016', '13:00:00 01-01-2016'),"
    insert_sql += "(4, 't3', 'b2', 2, '13:00:00 01-01-2016', '13:00:00 01-01-2016'),"
    insert_sql += "(6, 't3', 'b3', 3, '13:00:00 01-01-2016', '13:00:00 01-01-2016')"
    insert_sql
  end
  let(:updated_records) do
    [
      { 'id' => 3, 'title' => 't1', 'body' => 'b1', 'number' => 1, 'created_at' => '13:00:00 01-01-2016', 'updated_at' => '13:00:00 01-01-2016' },
      { 'id' => 4, 'title' => 't3', 'body' => 'b2', 'number' => 2, 'created_at' => '13:00:00 01-01-2016', 'updated_at' => '13:00:00 01-01-2016' },
      { 'id' => 6, 'title' => 't3', 'body' => 'b3', 'number' => 3, 'created_at' => '13:00:00 01-01-2016', 'updated_at' => '13:00:00 01-01-2016' }
    ]
  end
  let(:truncate_sql) { 'DELETE FROM items' }

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
    it 'matches the records exactly' do
      ActiveRecord::Base.connection.execute(some_records_insert_sql)
      Db::Sync.sync_up
      ActiveRecord::Base.connection.execute(truncate_sql)
    end

    it 'makes changes when neccessary' do
      ActiveRecord::Base.connection.execute(updated_records_insert_sql)
      Db::Sync.sync_up
      ActiveRecord::Base.connection.execute(truncate_sql)
    end
  end

  describe 'sync down' do
    it 'matches the records exactly' do
      ActiveRecord::Base.connection.execute(some_records_insert_sql)
      Db::Sync.sync_down
      save_stream.rewind
      data = save_stream.read
      expect(data).to eq(load_data)
      ActiveRecord::Base.connection.execute(truncate_sql)
    end
  end
end
