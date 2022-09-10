Rails.logger.info("-- Loading #{Rails.env.downcase} seeds file")

load(File.join(__dir__, 'seeds', "#{Rails.env.downcase}.rb")) if Rails.env.development?
