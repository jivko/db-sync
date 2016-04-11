class Db::Sync::Diff
  attr_accessor :original, :replace_with, :pkey
  attr_reader :inserts, :deletes, :updates

  def initialize(original, replace_with, pkey)
    self.original = original.collect
    self.replace_with = replace_with.collect
    self.pkey = pkey
    check_items
  end

  def next_original_item
    original.next
  rescue StopIteration
    nil
  end

  def next_replace_item
    replace_with.next
  rescue StopIteration
    nil
  end

  def check_items
    @inserts = []
    @deletes = []
    @updates = []
    original.rewind
    replace_with.rewind

    original_item = next_original_item
    replace_item = next_replace_item

    loop do
      cmp = compare(original_item, replace_item)
      if cmp == 0
        check_for_update(original_item, replace_item)
        original_item = next_original_item
        replace_item = next_replace_item
      elsif cmp > 0
        @inserts << replace_item
        replace_item = next_replace_item
      else
        @deletes << original_item.slice(*pkey)
        original_item = next_original_item
      end
      break if original_item.nil? && replace_item.nil?
    end
    nil
  end

  def check_for_update(original_item, replace_item)
    return if original_item.nil? || replace_item.nil?
    changes = {}
    replace_item.each do |key, value|
      next if value == original_item[key]
      changes[key] = value
    end
    return if changes.blank?
    @updates << { key: original_item.slice(*pkey), changes: changes }
  end

  def compare(item1, item2)
    return 0 if item1.nil? && item2.nil?
    return -1 if item2.nil?
    return 1 if item1.nil?
    self.class.compare(item1.slice(*pkey), item2.slice(*pkey))
  end

  def self.compare(item1, item2)
    result = item1.values <=> item2.values
    compare_count
    result
  end

  # TODO: remove, checks for number of comparisons
  def self.compare_count
  end
end
