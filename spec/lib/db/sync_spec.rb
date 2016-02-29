require 'spec_helper'

describe Db::Sync do
  let(:load_data) { '' }
  let(:save_stream) { StringIO.new }
  before(:each) do
    allow(File).to receive(:open).with('./db/data/items.yml', 'w').and_yield(save_stream)
    allow(File).to receive(:read).with('./db/data/items.yml').and_return(load_data)
    Db::Sync.configure do |config|
      config.tables = ['items']
    end
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
    let(:load_filename) { File.join(File.dirname(__FILE__), '..', '..', 'files', 'items.yml') }
    let(:load_data) { File.read(load_filename) }

    it 'uploads data from files' do
      Db::Sync.sync_up
    end
  end

  describe 'sync down' do
    it 'downloads tables to files' do
      Db::Sync.sync_down
      save_stream.rewind
      print save_stream.read
    end
  end
end
