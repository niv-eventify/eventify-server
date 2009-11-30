class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name_en
      t.string :name_he
      t.datetime :disabled_at
      t.timestamps 
    end

    add_index :categories, :disabled_at
  end

  def self.down
    drop_table :categories
  end
end