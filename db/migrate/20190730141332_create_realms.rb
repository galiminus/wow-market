class CreateRealms < ActiveRecord::Migration[5.2]
  def change
    create_table :realms do |t|
      t.string :region
      t.string :name
      t.string :slug
      t.string :battlegroup
      t.string :locale
      t.string :population
      
      t.timestamps
    end
  end
end
