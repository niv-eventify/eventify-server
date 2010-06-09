class AddFontParamsForTitleAndMessage < ActiveRecord::Migration
  def self.up
    add_column :events, :title_font_size, :integer, {:default => "35"}
    add_column :events, :msg_font_size, :integer, {:default => "32"}
    add_column :events, :title_text_align, :string
    add_column :events, :msg_text_align, :string
  end

  def self.down
    remove_column :events, :title_font_size
    remove_column :events, :msg_font_size
    remove_column :events, :title_text_align
    remove_column :events, :msg_text_align
  end
end
