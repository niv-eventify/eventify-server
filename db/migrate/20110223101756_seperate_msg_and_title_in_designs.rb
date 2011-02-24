class SeperateMsgAndTitleInDesigns < ActiveRecord::Migration
  def self.up
    Design.find(:all).each do |d|
      unless d.is_seperated_title?
        old_text_top_x = d.text_top_x
        old_text_top_y = d.text_top_y
        old_text_width = d.text_width
        old_text_height = d.text_height
        d.title_top_x = old_text_top_x
        d.title_top_y = old_text_top_y
        d.title_width = old_text_width
        d.title_height = (old_text_height.to_f / 4).ceil
        d.text_top_x = old_text_top_x
        d.text_top_y = old_text_top_y + ((old_text_height.to_f / 4).ceil) + 5
        d.text_width = old_text_width
        d.text_height = (old_text_height.to_f * 3 / 4).ceil
        d.save
      end
    end
  end

  def self.down
    Design.find(:all).each do |d|
      unless d.text_width != d.title_width || d.title_top_x != d.text_top_x
        d.text_top_y = d.title_top_y
        d.text_height = d.title_height * 4
        d.title_top_x = nil
        d.title_top_y = nil
        d.title_width = nil
        d.title_height = nil
        d.save
      end
    end
  end
end
