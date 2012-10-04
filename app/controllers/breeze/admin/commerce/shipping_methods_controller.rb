module Breeze
  module Admin
    module Commerce
      class ShippingMethodsController < Breeze::Admin::Commerce::Controller
        def index
          @shipping_methods = Breeze::Commerce::ShippingMethod.unarchived.where(:store_id => store.id).order_by(:created_at.desc).paginate(:page => params[:page], :per_page => 15)
        end
        
        def new
          @shipping_method = store.shipping_methods.new
        end
        
        def create
          @shipping_method = store.shipping_methods.build params[:shipping_method]
          if @shipping_method.save
            redirect_to admin_store_shipping_methods_path
          else
            render :action => "new"
          end
        end

        def edit
          @shipping_method = store.shipping_methods.find params[:id]
        end

        def update
          @shipping_method = store.shipping_methods.find params[:id]
          if @shipping_method.update_attributes(params[:shipping_method])
            flash[:notice] = "The shipping_method was saved."
            redirect_to admin_store_shipping_methods_path
          else
            render :action => "edit"
          end
        end

        def make_default
          @new_default_shipping_method = store.shipping_methods.find params[:id]
          set_default @new_default_shipping_method
          @shipping_methods = Breeze::Commerce::ShippingMethod.unarchived.where(:store_id => store.id).order_by(:created_at.desc).paginate(:page => params[:page], :per_page => 15)
        end
        
        
        def destroy
          @shipping_method = store.shipping_methods.find params[:id]
          @shipping_method.update_attributes(:archived => true)
          # if @shipping_method.is_default?
        end

        protected

        # TODO: Move this to shipping_method model
        def set_default(new_default_shipping_method)
          store.shipping_methods.where(:is_default => true).each do |old_default_shipping_method|
            old_default_shipping_method.update_attributes(:is_default => false) unless old_default_shipping_method == new_default_shipping_method
          end
          new_default_shipping_method.update_attributes(:is_default => true)
        end

      end
    end
  end
end