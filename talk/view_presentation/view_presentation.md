!SLIDE subsection transition=cover

# Sometimes, you need more help than helpers

!SLIDE transition=cover
# Let's tell a simple story

!SLIDE transition=cover bullets
# You need a profile page that shows a user
  * First Name
  * Last Name
  * Phone Number
  * Email
.notes Write a simple sinatra user and view

!SLIDE transition=cover
# Your stakeholder tells you to just display Full Name
.notes Add full_name virtual getter on User

!SLIDE transition=cover small
# Later they want the last 4 digits of the phone number masked if the the user viewing the profile is not a friend
.notes Add a masked_phone_number helper

!SLIDE transition=cover
# Your stakeholder later requests that only friends be able to see the email domain
.notes Add a masked_email helper

!SLIDE transition=cover small
# You realize they have a grouping in mind, and you have duplicate logic
.notes Extract to UnfriendlyUserPresentation
