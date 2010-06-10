module WindowsHelper
  def window_css(window, ratio = 1)
    window.window_dimensions(ratio).keys.map {|k| "#{k}:#{window.window_dimensions(ratio)[k]}"}.join(";")
  end
end
