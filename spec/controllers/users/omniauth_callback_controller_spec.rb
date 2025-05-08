require 'rails_helper'

describe Users::OmniauthCallbacksController do
  describe 'POST #discord' do
    let(:user) { create(:user) }
    let(:discord_id) { 123 }

    before do
      Rails.configuration.features[:discord_integration] = true
      sign_in user
      OmniAuth.config.add_mock(
        :discord,
        extra:       { raw_info: { 'id' => discord_id } },
        credentials: { token: 1234 }
      )
    end

    it 'allows users to link a Discord account' do
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      request.env['omniauth.params'] = { 'user_id' => user.id }
      post :discord, params: { id: user.id }
      user.reload
      expect(user.discord_id).to eq(discord_id)
    end

    let(:second_user) { create(:user) }
    it 'enforces Discord account uniqueness' do
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      request.env['omniauth.params'] = { 'user_id' => user.id }
      user_prev_id = user.discord_id
      second_user.update(discord_id: discord_id)
      second_user.reload

      post :discord, params: { id: user.id }
      user.reload
      expect(user.discord_id).to eq(user_prev_id)
    end
  end
end
