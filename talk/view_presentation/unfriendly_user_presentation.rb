class UnfriendlyUserPresentation < DelegateClass(User)
  alias :user :__getobj__

  def phone_number
    user.phone_number.gsub(/\d{4}$/, 'XXXX')
  end

  def email
    user.email.gsub(/@.+$/, '@hidden')
  end
end

module Helpers
  def masked_phone_number(user)
    if user.friends_with?(current_user)
      user.phone_number
    else
      user.phone_number.gsub(/\d{4}$/, 'XXXX')
    end
  end

  def masked_email(user)
    if user.friends_with?(current_user)
      user.email
    else
      user.email.gsub(/@.+$/, '@hidden')
    end
  end
end
