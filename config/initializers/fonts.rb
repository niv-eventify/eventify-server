if Rails.env.production?
  font_dir = File.join(ENV['HOME'], ".fonts")
  Dir.mkdir(font_dir) unless Dir.exists?(font_dir)

  Dir.glob(Rails.root.join("public", "fonts", "*")).each do |font|
    target = File.join(font_dir, File.basename(font))
    File.symlink(font, target) unless File.exists?(target)
  end
end

