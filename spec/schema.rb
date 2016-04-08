ActiveRecord::Schema.define do
  create_table :items, force: true do |t|
    t.string :title
    t.string :body
    t.integer :number
    t.boolean :available
    t.timestamps(null: false)
  end
end
