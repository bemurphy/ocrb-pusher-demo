!SLIDE subsection transition=cover bullets incremental
# Missing Domain Objects
* PORO to the rescue!

!SLIDE transition=cover
# It begins innocently.  Kind of.

!SLIDE transition=cover small bullets incremental
* Imagine we start introducing the notion of a coupon code to our app
* The first place it appears in our case is a controller.  Perhaps we're checking a param.
* We can tell if it's an affiliate code by checking if it starts with 'aff-'

!SLIDE transition=cover small
    @@@ ruby
    class ApplicationController

      private

      def affiliate_code?(code)
        true & code.to_s.match(/^aff-/)
      end
    end

!SLIDE transition=cover
# Yeah, that's questionable. Forging ahead.

!SLIDE transition=cover
# Oh hey, we later need that in the model

!SLIDE transition=cover small

    @@@ ruby
    class Sale < ActiveRecord::Base
      def affiliate_code?
        true & coupon_code.to_s.match(/^aff-/)
      end
    end

!SLIDE subsection transition=cover
# Something Smells in Here!

!SLIDE transition=cover small bullets incremental
# We keep talking about a Coupon Code

* But we are treating it _only_ as a string
* We are spreading our logic around.  Probably cut and paste style.
* We've got notions in the model that aren't at home there (so an Affiliate Coupon Code begins with aff-, you say?)

!SLIDE transition=cover
# We're missing a domain object!

!SLIDE transition=cover small

    @@@ ruby
    require 'delegate'

    class CouponCode < SimpleDelegator
      attr_accessor :code

      def initialize(code)
        @code = code
        super(@code)
      end

      def is_affiliate?
        true & code.to_s.match(/^aff-/)
      end
    end

!SLIDE transition=cover smaller

    @@@ ruby
    class Sale < ActiveRecord::Base
      composed_of :coupon_code,
        # The composition class name, if it can
        # be inferred it's automagic
        # I'm just putting for clarity
        :class_name => "CouponCode",

        # map my coupon code to the instance method code
        :mapping => %w(coupon_code code),

        # Allow setting as a String or CouponCode instance
        :converter => Proc.new { |cc| CouponCode.new(cc) }
    end

!SLIDE transition=cover smaller

    @@@ ruby
    sale.coupon_code = "foo"
    sale.coupon_code.is_affiliate?  # => false
    sale.coupon_code = "aff-foo"
    sale.coupon_code.is_affiliate?  # => true
    sale.coupon_code == "aff-foo" # => true
    sale.coupon_code == CouponCode.new("aff-foo") # => true


!SLIDE transition=cover bullets
* Materializing a thing that we've been using in conversation = big win!
* Centralized logic
