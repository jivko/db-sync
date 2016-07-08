class Db::Sync::Model < ActiveRecord::Base
  @abstract_class = true

  self.inheritance_column = nil

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

  def self.ordered_attributes
    pkey + (attribute_names - pkey).sort
  end

  def self.records
    attributes_order = ordered_attributes
    order(pkey).map do |record|
      res = {}
      attributes_order.each do |key|
        res[key] = record[key]
      end
      res
    end
  end
end
