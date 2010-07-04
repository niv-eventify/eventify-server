class AddTitleFontToDesigns < ActiveRecord::Migration
  def self.up
    add_column :designs, :font_title, :string
    rename_column :designs, :font, :font_body
    add_column :events, :font_title, :string
    rename_column :events, :font, :font_body

    Design.find_each(:batch_size => 10) do |d|
      d.font_title = d.font_body
      d.save
    end
  end

  def self.down
    rename_column :events, :font_body, :font
    remove_column :events, :font_title
    rename_column :designs, :font_body, :font
    remove_column :designs, :font_title
  end
end
