require 'rails_helper'

describe Users::OmniauthCallbacksController do
  describe 'POST #discord' do
    let(:user) { create(:user) }
    it 'sets discord_id to that incoming from Discord' do
      OmniAuth.config.add_mock(
        :discord,
        extra:       { raw_info: { 'id' => 123 } },
        credentials: { token: 1234 }
      )

      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      request.env['omniauth.params'] = { 'user_id' => user.id }

      post :discord, params: { id: user.id }

      expect(response).to have_http_status(:redirect)
    end
  end
end
