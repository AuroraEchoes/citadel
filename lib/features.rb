module Features
  def self.discord_integration_enabled?
    Rails.configuration.features[:discord_integration]
  end
end
