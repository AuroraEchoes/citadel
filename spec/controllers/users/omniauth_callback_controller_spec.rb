require 'rails_helper'

describe Users::OmniauthCallbacksController do
  describe 'POST #discord' do
    after do
      Rails.configuration.features[:discord_integration] = true
    end

    let(:user) { create(:user) }
    it 'allows users to link a Discord account' do
      discord_id = 123
      OmniAuth.config.add_mock(
        :discord,
        extra:       { raw_info: { 'id' => discord_id } },
        credentials: { token: 1234 }
      )

      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      request.env['omniauth.params'] = { 'user_id' => user.id }

      post :discord, params: { id: user.id }
      user.reload
      expect(user.discord_id).to eq(discord_id)
    end

    let(:second_user) { create(:user) }
    it 'enforces Discord account uniqueness' do
      discord_id = 123
      user_prev_id = user.discord_id
      second_user.update(discord_id: discord_id)
      second_user.reload

      OmniAuth.config.add_mock(
        :discord,
        extra:       { raw_info: { 'id' => discord_id } },
        credentials: { token: 1234 }
      )

      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      request.env['omniauth.params'] = { 'user_id' => user.id }

      post :discord, params: { id: user.id }
      user.reload
      expect(user.discord_id).to eq(user_prev_id)
    end

    it 'will not allow users to link an account when Discord integration is disabled' do
      Rails.configuration.features[:discord_integration] = false
      discord_id = 123
      OmniAuth.config.add_mock(
        :discord,
        extra:       { raw_info: { 'id' => discord_id } },
        credentials: { token: 1234 }
      )

      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      request.env['omniauth.params'] = { 'user_id' => user.id }

      post :discord, params: { id: user.id }
      user.reload
      expect(user.discord_id).to eq(nil)
    end
  end
end
