require 'logger'
module ImageMerger
  class << self
    def merge_two_images(top, bottom_pics, file_name)
      dst = Tempfile.new([file_name, ".png"])
      command = "composite -geometry #{bottom_pics[0][1]} #{bottom_pics[0][0]} #{RAILS_ROOT}/public/images/empty_invitation.png #{dst.path}"
      Paperclip.run(command)
      logger.debug(command)
      1.step(bottom_pics.length - 1) do |i|
        command = "composite -geometry #{bottom_pics[i][1]} #{bottom_pics[i][0]} #{dst.path} #{dst.path}"
        Paperclip.run(command)
        logger.debug(command)
      end
      command  = "composite #{top} #{dst.path} #{dst.path}"
      Paperclip.run(command)
      logger.debug(command)
      dst
    end
  end
end