class Db::Sync::Diff
  attr_accessor :original, :replace_with, :pkey

  def initialize(original, replace_with, pkey)
    self.original = original
    self.replace_with = replace_with
    self.pkey = pkey
  end

  def inserts
    results = []
    # change to iteration based
    replace_with.each do |item|
      found = search(original, item)
      results << item.dup if found.blank?
    end
    results
  end

  def deletes
    results = []
    # change to iteration based
    original.each do |item|
      found = search(replace_with, item)
      results << item.slice(*pkey) if found.blank?
    end
    results
  end

  def updates
    results = []
    # change to iteration based
    original.each do |item|
      found = search(replace_with, item)
      next if found.blank?
      next if found == item
      changes = {}
      found.each do |key, value|
        next if value == item[key]
        changes[key] = value
      end
      results << { key: item.slice(*pkey), changes: changes }
    end
    results
  end

  def search(stack, search_for)
    stack.each do |item|
      return item if item.slice(*pkey) == search_for.slice(*pkey)
    end
    false
  end
end
