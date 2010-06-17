module WindowsHelper
  def window_css(window, ratio = 1)
    win_dim = window.window_dimensions(ratio)
    win_dim.keys.map {|k| "#{k}:#{win_dim[k]}"}.join(";")
  end
end
