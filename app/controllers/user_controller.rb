class UserController < ApplicationController
  def index
    @user = User.all
    render json: @user, each_serializer: UserSerializer
  end

  def mass_update

    update_using_csv(params[:csv])

    message = Api::Message.new(:succesfully_updated)
    render json: message, serializer: MessageSerializer
  end

  private

  def update_using_csv(file)
    decoded_file = Base64.decode64(file)
    file = decoded_file.encode('utf-8', invalid: :replace, undef: :replace, replace: '')
    CSV.parse(file, headers: true).each_slice(100) do |mutations|
      ::MassUpdatePublisher.new(mutations).publish
    end
  end

  def update_balance(username, amount)
    user = User.find_by(username: username.to_s)
    user.balance += amount.to_i
    user.save!
  end
end
