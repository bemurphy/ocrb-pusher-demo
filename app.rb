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

Ohm.connect :db => 7

class Message < Ohm::Model
  include Ohm::Timestamping

  attribute :nickname
  attribute :content

  # Temporary id since we have no real users
  attr_accessor :user_ref

  def to_hash
    super.merge(
      :user_ref => user_ref,
      :nickname => nickname,
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
    create(
      :nickname => Faker::Name.first_name,
      :content => Faker::Lorem.sentence
    )
  end
end

class MessagePresentation < DelegateClass(Message)
  def humanize_time
    time = Time.parse(created_at)
    tz.utc_to_local(time).strftime("%I:%M %p")
  end

  def to_hash
    super.merge(:humanize_time => humanize_time)
  end

  private

  def tz
    # Hardcoded for demo purposes
    TZInfo::Timezone.get('America/Los_Angeles')
  end
end

class App < Sinatra::Base
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

    def user_ref
      SecureRandom.uuid
    end

    def present(item, klass = nil)
      klass ||= Object.const_get("#{item.class}Presentation")
      klass.new(item)
    end
  end

  helpers Helpers

  get "/" do
    messages = Message.all_or_seed.map{|m| present(m)}
    mustache :index, :locals => {
      :messages => messages,
      :message_template => mustache_template("message") }
  end

  post "/messages" do
    content_type :json

    # We're gonna talk about this later...
    message = present(Message.create(params))

    # ...and this too!
    Pusher['messages'].trigger_async('create', message.to_hash)

    { :status => "ok", :message => message.to_hash }.to_json
  end

  get "/flush" do
    Ohm.redis.flushdb
    redirect "/"
  end
end
