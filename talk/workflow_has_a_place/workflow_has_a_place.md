!SLIDE subsection transition=cover

# Workflow Has a Place

!SLIDE small transition=cover

    @@@ ruby
    # Think back to the Pusher demo
    post "/messages", :provides => :json do
      if current_user
        message = present(Message.create(
          :user_id => current_user.id,
          :content => params["content"]))

        Pusher['messages'].trigger_async('create',
          message.to_hash)

        {
          :status => "ok",
          :message => message.to_hash
        }.to_json
      else
        halt 401
      end
    end

!SLIDE transition=cover bullets incremental

* The controller asks
* What is this Pusher thing?

!SLIDE transition=cover bullets incremental

* ...and then protests
* I'm just a front controller!

!SLIDE subsection transition=cover

# Let's Order a Steak

.notes Start with done-ness

!SLIDE subsection transition=cover smaller
        @@@ ruby
        class Message < SomeOrmBaseClass
          after :create, :push

          private

          def  push
            Pusher['messages'].trigger_async('create',
              to_hash)
          end
        end

!SLIDE transition=cover bullets incremental

* The model asks
* What is this Pusher thing?

!SLIDE transition=cover bullets incremental

* Your unit tests ask
* What is this pusher thing, and furthermore, why are you always stubbing it out?

!SLIDE transition=cover
# Let's extract the workflow

!SLIDE subsection transition=cover smaller
        @@@ ruby

        module MessageWithPushService
          def self.create(params)
            msg = Message.create(params)
            msg = MessagePresentation.new(msg)

            Pusher['messages'].trigger_async('create',
              msg.to_hash)

            msg
          end
        end

!SLIDE subsection transition=cover smaller
        @@@ ruby
        post "/messages", :provides => :json do
          if current_user
            message = MessageWithPushService.create(
              :user_id => current_user.id,
              :content => params["content"])

            {
              :status => "ok",
              :message => message.to_hash
            }.to_json
          else
            halt 401
          end
        end

!SLIDE transition=cover bullets incremental

# What we have now

* The ability to create a message without callbacks pushing
* The ability to create messages with test factories, without pushing
* ...while still having reusability
