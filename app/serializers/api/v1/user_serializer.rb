module API
  module V1
    class UserSerializer < ActiveModel::Serializer
      type :user

      attributes :id, :name, :description, :created_at
      attributes :steam_32, :steam_64, :steam_id3, :discord_id
      attribute(:steam_64_str) { object.steam_64.to_s } # For dumb json implementations
      attribute(:profile_url) { object.avatar.thumb.url }

      attribute(:is_captain, if: -> { scope.is_a? Team }) do
        object.can?(:edit, scope)
      end

      has_many :teams, serializer: API::V1::TeamSerializer
      has_many :rosters, serializer: API::V1::Leagues::RosterSerializer
    end
  end
end
