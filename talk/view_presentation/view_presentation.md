!SLIDE subsection transition=cover

# Sometimes, you need more help than helpers

!SLIDE transition=cover
# Let's code a simple story

!SLIDE transition=cover bullets
# You need a profile page that shows a user
* First Name
* Last Name
* Phone Number
* Email

.notes Write a simple sinatra user and view

!SLIDE transition=cover
# Let's take a look

!SLIDE transition=cover
# Your stakeholder tells you to just display Full Name
.notes Add full_name virtual getter on User

!SLIDE transition=cover
# Time for some typing.

!SLIDE transition=cover small
# Later they want the last 4 digits of the phone number masked if the the user viewing the profile is not a friend
.notes Add a masked_phone_number helper

!SLIDE transition=cover
# To the code!

!SLIDE transition=cover
# Your stakeholder later requests that only friends be able to see the email domain
.notes Add a masked_email helper

!SLIDE transition=cover
# Back to vim

!SLIDE transition=cover small
# You realize they have a grouping in mind, and you have duplicate logic
.notes Extract to UnfriendlyUserPresentation

!SLIDE transition=cover
# Encapsulate!

!SLIDE transition=cover bullets small
* Encapsulation
* Less pollution of our controllers/views
* Kill duplicated conditional checks
* Logical correlations.  We've given something more context
* Less view level concerns sneaking into our models
