module Breeze
  module Commerce
    class Product < Breeze::Content::Page
      include Mixins::Archivable
      include Mixins::Publishable

      attr_accessible :view, :order, :template, :title, :subtitle, 
        :show_in_navigation, :ssl, :seo_title, :seo_meta_description, 
        :seo_meta_keywords, :show_in_navigation, :teaser, :tag_ids, 
        :property_ids, :parent_id, :options, :slug, :position

      has_and_belongs_to_many :tags, :class_name => "Breeze::Commerce::Tag"
      has_and_belongs_to_many :properties, :class_name => "Breeze::Commerce::Property"

      has_many :images, :class_name => "Breeze::Commerce::ProductImage"
      belongs_to :default_image, :class_name => "Breeze::Commerce::ProductImage"
      
      has_many :product_relationship_children, :class_name => "Breeze::Commerce::ProductRelationship", :inverse_of => :parent_product
      has_many :product_relationship_parents, :class_name => "Breeze::Commerce::ProductRelationship", :inverse_of => :child_product
      has_many :variants, :class_name => "Breeze::Commerce::Variant"

      field :show_in_navigation, :type => Boolean, :default => false
      field :teaser

      default_scope order_by([:title, :asc])
      scope :with_tag, lambda { |tag| where(tag_ids: tag.id) }

      before_validation :set_parent_id
      validates_associated :variants

      alias_method :name, :title
      alias_method :name=, :title=

      def related_products
        product_relationship_children.collect(&:child_product)
      end
      
      def display_price_min
        variants.unarchived.published.map(&:display_price).min
      end
      alias_method :display_price, :display_price_min

      def display_price_max
        variants.unarchived.published.map(&:display_price).max
      end

      # Are all the variants the same price?
      def single_display_price?
        variants.unarchived.published.map(&:display_price).uniq.size < 2
      end

      # Are any of the product's variants discounted?
      def any_variants_discounted?
        variants.unarchived.published.discounted.exists?
      end

      # Are all of the product's variants discounted?
      def all_variants_discounted?
        variants.present? && !variants.unarchived.published.not_discounted.exists?
      end

      def last_update
        if updated_at.to_date == Time.zone.now.to_date
          updated_at.strftime('%l:%M %p') # e.g. 3:52 PM
        else
          updated_at.strftime('%A %d %B %Y, %l:%M %p') # e.g. 3:52 PM
        end
      end

      def number_of_sales
        variants.unarchived.sum(&:number_of_sales)
      end

      # Convenience method for designers
      # ... allows setting up a conditional in product listing theme partials 
      # without having to know how to find a tag in the database
      def has_tag_named? tag_name
        looked_up_tag_id = Breeze::Commerce::Tag.where(name: tag_name).only(:id).first.try(:id)
        tag_ids.include? looked_up_tag_id
      end

      # # Create a variant for each combination of property options
      # # e.g. if a product has colours red, green and blue and sizes small, medium and large, this will create a small red variant, a medium red variant, a large red variant, asmall green variant and so forth
      # def generate_variants( sell_price_cents )
      #   option_arrays = properties.map{ |property| property.options }
      #   variants_array = combine_arrays( *option_arrays ) do | *args |
      #     name = self.name + " " + args.map{ |option| option.name}.join(" ")
      #     sku_code = name.downcase.gsub(" ", "_")
      #     foo = Breeze::Commerce::Variant.new product: self, name: name, sku_code: sku_code, sell_price_cents: sell_price_cents, published: true
      #     args.each do |option|
      #       foo.options << option
      #     end
      #     foo.save
      #   end
      # end

      def copy_properties_from( product )
        product.properties.each do | property |
          new_property = properties.create( name: property.name )
          property.options.each do | option |
            new_property.options.create( name: option.name )
          end
        end
      end

    private

      # def combine_arrays(*arrays)
      #   if arrays.empty?
      #     yield
      #   else
      #     first, *rest = arrays
      #     first.map do |x|
      #       combine_arrays(*rest) {|*args| yield x, *args }
      #     end.flatten
      #       #.flatten(1)
      #   end
      # end

      # If a product is created under store admin, set the root page, if any, as the parent
      def set_parent_id
        unless self.parent_id
          self.parent_id = Breeze::Content::NavigationItem.root.first.id if Breeze::Content::NavigationItem.root.first
        end
      end

    end
  end
end
