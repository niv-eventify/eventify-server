class CreateClassifications < ActiveRecord::Migration
  def self.up
    create_table :classifications do |t|
      t.column :category_id, :integer
      t.column :design_id, :integer
      t.timestamps
    end

    add_index :classifications, :category_id
    add_index :classifications, :design_id
    Design.find_each(:batch_size => 10) do |d|
      Classification.create(:design_id => d.id, :category_id => d.category_id)
    end

    remove_index  :designs, :category_id
    remove_column :designs, :category_id

    add_column :categories, :root, :boolean, :default => false
    c = Category.new(:name_en => "All", :name_he => "הכל")
    c.root = true
    c.save

    add_index :categories, :root

    Design.find_each(:batch_size => 10) do |d|
      Classification.create(:design_id => d.id, :category_id => c.id)
    end
  end

  def self.down

    remove_index :categories, :root

    Category.first(:conditions => {:root => true}).destroy
    remove_column :categories, :root

    add_column :designs, :category_id, :integer
    add_index  :designs, :category_id

    Design.find_each(:batch_size => 10) do |d|
      d.category_id = d.classifications.first.category_id
      d.save
    end

    drop_table :classifications
  end
end
