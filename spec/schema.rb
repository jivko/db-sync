ActiveRecord::Schema.define do
  create_table :items, force: true do |t|
    t.string :title
    t.string :body
    t.integer :number
    t.timestamps(null: false)
  end
end
