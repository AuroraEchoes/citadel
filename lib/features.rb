module Features
  def self.discord_integration_enabled?
    Rails.configuration.features[:discord_integration]
  end

  def self.name_filtering_enabled?
    Rails.configuration.features[:name_filtering][:enabled]
  end

  def self.name_filter
    Regexp.new Rails.configuration.features[:name_filtering][:filter]
  end
end
