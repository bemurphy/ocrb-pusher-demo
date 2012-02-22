!SLIDE subsection transition=cover

# (Un)commonly Bad Coupling

.notes this is a pun because the coupling is bad but it is common in Rails apps

!SLIDE subsection small transition=cover bullets incremental

# Background Jobs...

* Everybody uses them
* How many have used Delayed::Job?  How many Resque?
* How many have migrated from DJ to Resque, or seen it done recently?
* How many have seen this in a callback?

!SLIDE small transition=cover

    @@@ ruby
    class User < SomeOrmClass
      after :create, :send_welcome

      private

      def send_welcome
        Delayed::Job.enqueue(WelcomeJob.new(self))
        # or Resque.enqueue(WelcomeJob, self.id), etc
      end
    end

    class WelcomeJob < Struct.new(:user)
      def perform
        UserNotifier.welcome(user)
      end
    end

!SLIDE transition=cover bullets incremental

# Our model now couples to
* The job (less bad)
* Implementation details about queueing the job (wow, bad)

!SLIDE transition=cover bullets incremental

# Let's try a tiny change

!SLIDE small transition=cover

    @@@ ruby
    class WelcomeJob < Struct.new(:user)
      # Hide the queueing implementation
      def self.enqueue(user)
        Delayed::Job.enqueue(new user))
      end

      def perform
        UserNotifier.welcome(user)
      end
    end

    class User < SomeOrmClass
      def send_welcome
        # Only talk to the job class
        WelcomeJob.enqueue(self)
      end
    end

!SLIDE smaller transition=cover bullets incremental

* But if I refactor I still have to change that!
* Yes, but you're changing it in a better place.  Common closure!
* Imagine a job that is used by multiple models: a similar email is generated to an admin when a User, Post, Project, or Page is updated
* What if you farm different jobs to different libraries, or are migrating?
* Delayed::Job serializes objects;  Resque takes JSON-ables.  Change implementation details closer to where it matters.
