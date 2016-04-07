require 'spec_helper'

describe Db::Sync::Diff do
  let(:original) do
    [
      { 'id' => 1, 'title' => 't1', 'body' => 'b1' },
      { 'id' => 2, 'title' => 't2', 'body' => 'b2' },
      { 'id' => 3, 'title' => 't3', 'body' => 'b3' },
    ]
  end
  let(:replace_with) do
    [
      { 'id' => 1, 'title' => 't1', 'body' => 'b1' },
      { 'id' => 2, 'title' => 't3', 'body' => 'b2' },
      { 'id' => 4, 'title' => 't3', 'body' => 'b3' },
    ]
  end
  let(:pkey) { ['id'] }
  let(:diff) { Db::Sync::Diff.new(original, replace_with, pkey) }

  describe 'inserts' do
    it 'are correct' do
      expect(diff.inserts).to eq([{ 'id' => 4, 'title' => 't3', 'body' => 'b3' }])
    end
  end

  describe 'deletes' do
    it 'are correct' do
      expect(diff.deletes).to eq([{ 'id' => 3 }])
    end
  end

  describe 'updates' do
    it 'are correct' do
      expect(diff.updates).to eq([{ key: { 'id' => 2 }, changes: { 'title' => 't3'} }])
    end
  end
end
