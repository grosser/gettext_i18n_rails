#gettext requires locale, so it shall have it :P
module Locale
  extend self
  def candidates(*i_do_not_care)
    GetText.locale
  end
end

module Locale
  module Tag
    class Posix
    end
  end
end