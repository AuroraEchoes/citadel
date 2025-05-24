module API
  module V1
    class UsersController < APIController
      include Features

      def show
        @user = User.find(params[:id])

        render json: @user, serializer: UserSerializer
      end

      def steam_id
        @user = User.find_by!(steam_id: params[:id])

        render json: @user, serializer: UserSerializer
      end

      def discord_id
        @user = User.find_by!(discord_id: params[:id])
        render json: @user, serializer: UserSerializer
      end
    end
  end
end
