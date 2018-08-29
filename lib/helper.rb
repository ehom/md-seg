module Helper
  @@logger = nil
  def self.logger
    if @@logger.nil?
      @@logger = Logger.new(STDOUT)
    end
    @@logger
  end
end