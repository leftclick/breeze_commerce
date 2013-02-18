# Stores settings for Breeze Commerce
module Breeze
  module Commerce
    class Store
      include Mongoid::Document

      attr_accessible :home_page_id, :terms_page_id, :allow_returning_customer_login, :currency, :default_shipping_method, :default_shipping_method_id, :default_country_id, :default_country

      belongs_to :home_page, :class_name => "Breeze::Content::Page"   # The root page for the store, which might be different from the root page for the site
      belongs_to :terms_page, :class_name => "Breeze::Content::Page"  # The page with terms and conditions which a customer must agree to before checking out
      belongs_to :default_shipping_method, :class_name => "Breeze::Commerce::ShippingMethod"
      belongs_to :default_country, :class_name => "Breeze::Commerce::Country"
      field :allow_returning_customer_login, type: Boolean, default: true
      field :currency, default: 'NZD'
      
      alias_method :associated_default_country, :default_country
      def default_country
        self.associated_default_country || Breeze::Commerce::Country.first
      end

    end
  end
end
