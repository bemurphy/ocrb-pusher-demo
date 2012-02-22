desc "Run the slides using showoff"
task :slides do
  `cd talk && bundle exec showoff serve`
end

desc "Start the Pusher demo"
task :pusher do
  `bundle exec rackup`
end

desc "Start the View Presentation app"
task :presenters do
  `cd talk/view_presentation && bundle exec shotgun app.rb`
end
