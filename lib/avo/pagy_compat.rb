module Avo
  # Pagy 43 replaced Pagy::Backend, Pagy::Frontend and the extras with Pagy::Method and helpers on the
  # Pagy instance. Avo 3 keeps supporting Pagy 7 to 9, so each place that differs asks this module.
  module PagyCompat
    def self.pagy_43?
      ::Gem::Version.new(::Pagy::VERSION) >= ::Gem::Version.new("43.0")
    end

    def self.backend
      pagy_43? ? ::Pagy::Method : ::Pagy::Backend
    end

    # Raised for a page outside the range, for example after the last record of the last page was deleted.
    def self.page_out_of_range_error
      pagy_43? ? ::Pagy::RangeError : ::Pagy::OverflowError
    end

    # Pagy 43 calls the `size` option `slots` and accepts only an Integer. Pagy 7 also accepted an Array
    # like `[1, 2, 2, 1]`: pages at the start, before the current page, after it, and at the end. It shows
    # those pages, the current page and two gaps, so the same nav needs three slots more than its sum.
    def self.slots(size)
      return size unless size.is_a?(Array)

      size.sum.zero? ? 0 : size.sum + 3
    end

    # Pagy 43 keeps its locale in a thread variable. Set it only while Avo renders, so that the next
    # request on the same thread, and the host app, do not get Avo's locale.
    def self.with_locale(locale)
      previous_locale = ::Pagy::I18n.locale
      ::Pagy::I18n.locale = locale
      yield
    ensure
      ::Pagy::I18n.locale = previous_locale
    end
  end
end
