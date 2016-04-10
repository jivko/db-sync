require 'spec_helper'

describe Db::Sync::Diff do
  let(:original) do
    [
      { 'id' => 1, 'title' => 't1', 'body' => 'b1' },
      { 'id' => 2, 'title' => 't2', 'body' => 'b2' },
      { 'id' => 3, 'title' => 't3', 'body' => 'b3' },
      { 'id' => 5, 'title' => 't5', 'body' => 'b5' },
      { 'id' => 7, 'title' => 't7', 'body' => 'b7' },
      { 'id' => 8, 'title' => 't8', 'body' => 'b8' },
      { 'id' => 9, 'title' => 't9', 'body' => 'b9' }
    ]
  end
  let(:replace_with) do
    [
      { 'id' => 1, 'title' => 't1', 'body' => 'b1' },
      { 'id' => 2, 'title' => 't3', 'body' => 'b2' },
      { 'id' => 5, 'title' => 't5', 'body' => 'b5' },
      { 'id' => 6, 'title' => 't6', 'body' => 'b6' },
      { 'id' => 7, 'title' => 't7', 'body' => 'b7' },
      { 'id' => 8, 'title' => 't8', 'body' => 'b8' },
      { 'id' => 9, 'title' => 't9', 'body' => 'b9' }
    ]
  end
  let(:pkey) { ['id'] }
  let(:diff) { Db::Sync::Diff.new(original, replace_with, pkey) }

  let(:edge_original) { [{ 'id' => 1, 'data' => 1 }] }
  let(:edge_replace) { [{ 'id' => 2, 'data' => 1 }] }
  let(:edge_diff) { Db::Sync::Diff.new(edge_original, edge_replace, pkey) }

  describe 'inserts' do
    it 'are correct' do
      expect(diff.inserts).to eq([{ 'id' => 6, 'title' => 't6', 'body' => 'b6' }])
    end

    it 'works with edge cases' do
      expect(edge_diff.inserts).to eq([{ 'id' => 2, 'data' => 1 }])
    end
  end

  describe 'deletes' do
    it 'are correct' do
      expect(diff.deletes).to eq([{ 'id' => 3 }])
    end

    it 'works with edge cases' do
      expect(edge_diff.deletes).to eq([{ 'id' => 1 }])
    end
  end

  describe 'updates' do
    it 'are correct' do
      expect(diff.updates).to eq([{ key: { 'id' => 2 }, changes: { 'title' => 't3'} }])
    end
  end

  describe 'diff' do
    it 'has reduced iterations' do
      expect(Db::Sync::Diff).to receive(:compare_count).exactly(8).times
      diff.updates
      diff.inserts
      diff.deletes
    end
  end
end
