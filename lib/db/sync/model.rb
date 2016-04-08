class Db::Sync::Model < ActiveRecord::Base
  @abstract_class = true

  def unique_data
    attributes.slice(*self.class.pkey)
  end

  def compare_unique_data(other)
    self.class.pkey.each do |key|
      attributes[key] <=> other[key]
    end
  end

  def self.include_id?
    attribute_names.include?('id')
  end

  def self.pkey
    if include_id?
      ['id']
    else
      attribute_names.sort
    end
  end

  def self.records
    order(pkey)
  end
end
