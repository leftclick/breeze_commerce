module Breeze
  module Commerce
    class Address
      include Mongoid::Document
      include Mixins::Archivable

      embedded_in :order, :class_name => "Breeze::Commerce::Order", :inverse_of => :shipping_address
      embedded_in :order, :class_name => "Breeze::Commerce::Order", :inverse_of => :billing_address
      embedded_in :customer, :class_name => "Breeze::Commerce::Customer", :inverse_of => :shipping_address
      embedded_in :customer, :class_name => "Breeze::Commerce::Customer", :inverse_of => :billing_address

      attr_accessible :name, :address, :city, :state, :postcode, :country, :phone
      field :name
      field :address # May be multi-line
      field :city
      field :state
      field :postcode
      field :country
      field :phone

      validates_presence_of :name, :address, :city
      
      def to_s
        result = ''
        result += (name || 'Unknown Name') + "\n"
        result += (address || '') + "\n"
        result += (city || '') + "\n"
        result += (state || '') + "\n"
        result += (postcode || '') + "\n"
        result += (country || '') + "\n"
        (result += 'Contact Phone:' + phone) if phone
      end
    end
  end
end
