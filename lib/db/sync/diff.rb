class Db::Sync::Diff
  attr_accessor :left, :right, :pkey

  def initialize(left, right, pkey)
    self.left = left
    self.right = right
    self.pkey = pkey
  end

  def inserts
    results = []
    # change to iteration based
    left.each do |item|
      found = search(right, item)
      results << item if found.blank?
    end
    results
  end

  def deletes
    results = []
    # change to iteration based
    right.each do |item|
      found = search(left, item)
      results << item if found.blank?
    end
    results
  end

  def updates
    results = []
    # change to iteration based
    left.each do |item|
      found = search(right, item)
      next if found.blank?
      next if found == item
      print "old\n"
      print found, "\n"
      print "new\n"
      print item, "\n"
      results << item
    end
    results
  end

  def search(stack, search_for)
    stack.each do |item|
      return item if item.slice(*pkey) == search_for.slice(*pkey)
    end
  end
end
