require 'rails_helper'

describe API::V1::UsersController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:user) { create(:user) }

  describe 'GET #show' do
    let(:route) { '/api/v1/users' }

    it 'succeeds for existing user' do
      teams = create_list(:team, 3)
      teams.each { |team| team.add_player!(user) }
      rosters = create_list(:league_roster, 2)
      rosters.each { |roster| roster.add_player!(user) }

      get "#{route}/#{user.id}", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      user_h = json['user']
      expect(user_h).to_not be_nil
      expect(user_h['name']).to eq(user.name)

      expect(user_h['rosters'].length).to eq(rosters.length)
      user_h['rosters'].each do |roster|
        expect(rosters.map(&:id)).to include(roster['id'])
      end

      expect(user_h['teams'].length).to eq(teams.length)
      user_h['teams'].each do |team|
        expect(teams.map(&:id)).to include(team['id'])
      end

      expect(response).to be_successful
    end

    it 'succeeds for non-existent user' do
      get "#{route}/-1", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end

    it 'fails without authorization' do
      get "#{route}/#{user.id}"

      json = response.parsed_body
      expect(json['status']).to eq(401)
      expect(json['message']).to eq('Unauthorized API key')
    end
  end

  describe 'GET #steam_id' do
    let(:route) { '/api/v1/users/steam_id' }

    it 'succeeds for existing user' do
      get "#{route}/#{user.steam_id}", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      user_h = json['user']
      expect(user_h).to_not be_nil
      expect(user_h['name']).to eq(user.name)
      expect(user_h['teams']).to be_empty
      expect(user_h['rosters']).to be_empty
      expect(response).to be_successful
    end

    it 'succeeds for non-existent user' do
      get "#{route}/0", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end
  end

  describe 'GET #discord_id' do
    let(:user) { create(:user_with_discord) }
    let(:route) { '/api/v1/users/discord_id' }

    context 'with Discord integration enabled' do
      before do
        allow(Features).to receive(:discord_integration_enabled?).and_return(true)
        Rails.application.reload_routes!
      end

      it 'succeeds for existing user' do
        get "#{route}/#{user.discord_id}", headers: { 'X-API-Key' => api_key.key }

        json = response.parsed_body
        user_h = json['user']
        expect(user_h).to_not be_nil
        expect(user_h['name']).to eq(user.name)
        expect(user_h['teams']).to be_empty
        expect(user_h['rosters']).to be_empty
        expect(user_h['discord_id']).to be(user.discord_id)
        expect(response).to be_successful
      end

      it 'fails for non-existent user' do
        get "#{route}/0", headers: { 'X-API-Key' => api_key.key }

        json = response.parsed_body
        expect(json['status']).to eq(404)
        expect(json['message']).to eq('Record not found')
        expect(response).to be_not_found
      end
    end
    context 'with Discord integration disabled' do
      before do
        allow(Features).to receive(:discord_integration_enabled?).and_return(false)
        Rails.application.reload_routes!
      end

      it 'cannot route by Discord ID' do
        expect { get "#{route}/#{user.discord_id}" }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
