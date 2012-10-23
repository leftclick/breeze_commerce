module Breeze
  module Commerce
    class View < Breeze::Content::PageView
      def store
        content
      end

      def products
        Breeze::Commerce::Product.all
      end

      def with_url_params(match)
        dup.tap do |view|
          view.set_url_params(match)
        end
      end

      def set_url_params(match)
      end

      def template
        if content.template.blank?
          "breeze/commerce/#{name}"
        else
          content.template
        end
      end
      
      def variables_for_render
        super.tap do |vars|
          vars[:products] = products
        end
      end
      
    end
  end
end
