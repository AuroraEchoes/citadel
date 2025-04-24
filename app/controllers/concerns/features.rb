module Features
  extend ActiveSupport::Concern

  def discord_integration_enabled?
    Rails.configuration.features[:discord_integration]
  end
end
