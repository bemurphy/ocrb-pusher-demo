require 'sinatra'
require 'ostruct'

class User < OpenStruct
  def friends_with?(user)
    true
  end
end

helpers do
  def current_user
    @current_user ||= User.new
  end
end

# Let us ignore the non-RESTfulness
get "/" do
  @user = User.new({
    :first_name   => "John",
    :last_name    => "Doe",
    :phone_number => "949-555-1212",
    :email        => "john.doe@example.com"
  })

  erb :index
end
