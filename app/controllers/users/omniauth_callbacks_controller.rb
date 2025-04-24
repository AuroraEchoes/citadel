module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Don't need to protect against forgery for omniauth logins
    skip_before_action :verify_authenticity_token

    def steam
      auth = request.env['omniauth.auth']

      user = User.find_by(steam_id: auth.uid)

      if user
        sign_in_and_redirect user
      else
        session['devise.steam_data'] = auth.except('extra').except('info')
        redirect_to new_user_path(name: auth.info.nickname)
      end
    end

    def discord
      auth = request.env['omniauth.auth']
      params = request.env['omniauth.params']
      user_id = params['user_id']
      discord_id = auth.extra.raw_info['id']
      discord_revoke_token(auth.credentials.token)
      redirect_to link_discord_user_path(id: user_id, discord_id: discord_id), method: :patch
    end

    def discord_revoke_token(token)
      uri = URI.parse("https://discord.com/api/oauth2/token/revoke?token=#{token}")
      http = Net::HTTP.new(uri.host, uri.port)
      post = Net::HTTP::Post.new(uri.to_s)
      http.request(post)
    end

    def failure
      redirect_back(fallback_location: root_path)
    end
  end
end
