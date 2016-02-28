require 'spec_helper'

describe Db::Sync do
  before(:each) do
    Db::Sync.configure do |config|
      config.tables = ['items']
    end
  end

  it 'has a version number' do
    expect(Db::Sync::VERSION).not_to be nil
  end

  it 'has tables config' do
    expect(Db::Sync.config.tables).to contain_exactly('items')
  end

  describe 'sync' do
    it 'works with configured tables' do
      expect(Db::Sync.working_tables).to contain_exactly('items')
    end

    it 'uploads data from files' do
      Db::Sync.sync_up
    end

    it 'downloads tables to files' do
      Db::Sync.sync_down
    end
  end
end
