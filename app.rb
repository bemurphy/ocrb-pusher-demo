require 'sinatra/base'
require 'mustache'
require 'mustache/sinatra'
require 'faker'
require 'pusher'
require 'ohm'
require 'ohm/contrib'
require 'securerandom'
require 'tzinfo'
require 'delegate'
require 'json'

Ohm.connect :db => 7

class User < Ohm::Model
  include Ohm::Callbacks

  attribute :nickname
  index :nickname

  collection :messages, Message

  before :save, :downcase_nickname 

  def validate
    assert_unique :nickname
  end

  def self.find_or_create(nickname)
    nickname.downcase!
    find(:nickname => nickname).first || create(:nickname => nickname)
  end

  def self.create_fake
    create(:nickname => Faker::Name.first_name)
  end

  private

  def downcase_nickname
    nickname.downcase! if nickname
  end
end

class Message < Ohm::Model
  include Ohm::Timestamping

  attribute :content
  reference :user, User

  def to_hash
    super.merge(
      :user_id => user_id,
      :content => content,
      :created_at => created_at
    )
  end

  def self.all_or_seed(n = 9)
    if all.count == 0
      n.times.collect { create_fake }
    end

    all.to_a.reverse
  end

  def self.create_fake
    user = User.create_fake
    create(
      :user_id => user.id, 
      :content => Faker::Lorem.sentence
    )
  end
end

class MessagePresentation < DelegateClass(Message)
  def humanize_time
    time = Time.parse(created_at)
    tz.utc_to_local(time).strftime("%I:%M %p")
  end

  def user_nickname
    user.nickname
  end

  def to_hash
    super.merge(:user_nickname => user_nickname, :humanize_time => humanize_time)
  end

  private

  def tz
    # Hardcoded for demo purposes
    TZInfo::Timezone.get('America/Los_Angeles')
  end
end

class App < Sinatra::Base
  enable :sessions
  set :session_secret, "de8deb5264a4b68606210cb60776d531"

  register Mustache::Sinatra
  module Views; end
  set :mustache, {
    :views => "./views",
    :templates => "./templates"
  }

  configure do
    Pusher.app_id = '15429'
    Pusher.key = '35e98fc9d7c113c3ba1d'
    Pusher.secret = ENV.fetch("OCRB_PUSHER_SECRET")
  end

  # Modularize so we can include in Mustache views
  module Helpers
    def mustache_template_cache
      Thread.current[:mustache_template_cache] ||= Tilt::Cache.new
    end

    def mustache_template(template)
      # Cheap monkeybusiness enforcement
      raise SecurityError unless template =~ /^[a-z]+$/

      mustache_template_cache.fetch template do
        File.open("./templates/#{template}.mustache", "r").read
      end
    end

    def present(item, klass = nil)
      klass ||= Object.const_get("#{item.class}Presentation")
      klass.new(item)
    end

    def current_user
      return unless session
      @current_user ||= User[session["user_id"]]
    end

    def current_user_id
      current_user.id
    end
  end

  helpers Helpers

  # Set the session accessible for Mustache, kinda lame
  before { @session = session } 

  get "/" do
    redirect "/login" unless current_user

    messages = Message.all_or_seed.map{|m| present(m)}
    mustache :index, :locals => {
      :messages => messages,
      :message_template => mustache_template("message") }
  end

  get "/login" do
    redirect "/" if current_user
    mustache :login
  end

  delete "/logout" do
    session[:user_id] = nil
    redirect "/login"
  end

  post "/login" do
    user = User.find_or_create(params["nickname"])
    session["user_id"] = user.id
    redirect "/"
  end

  post "/messages" do
    if current_user
      content_type :json

      # We're gonna talk about this later...
      message = present(Message.create(:user_id => current_user.id, :content => params["content"]))

      # ...and this too!
      Pusher['messages'].trigger_async('create', message.to_hash)

      { :status => "ok", :message => message.to_hash }.to_json
    else
      halt 401
    end
  end

  get "/flush" do
    Ohm.redis.flushdb
    redirect "/"
  end

  post "/pusher/auth", :provides => :json do
    if current_user
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
        :user_id => current_user.id,
        :user_info => {
          :nickname => current_user.nickname
        }})
      response.to_json
    else
      halt 401
    end
  end
end
