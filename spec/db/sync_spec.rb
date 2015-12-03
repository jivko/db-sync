require 'spec_helper'

describe Db::Sync do
  it 'has a version number' do
    expect(Db::Sync::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
