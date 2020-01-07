require 'json'
require 'faraday'

class AppProxyController < ApplicationController
	include ShopifyApp::AppProxyVerification
	include LabelUtilities, RefundUtilities, ShopUtilities

	def index
		@refund_filter = params[:refund_filter] || 'in-progress'

		@refunds = apply_filter(@refund_filter)

		unless params[:search].nil? or params[:search].empty?
			@results = apply_search(params[:search])
			@refunds = @refunds & @results
		end

		@pagination_total = @refunds.count 
		@pagination_current = [params[:pagination_current].to_i, 1].max
		@pagination_size = 10

		@refund_requests = Kaminari.paginate_array(@refunds).page(@pagination_current).per(@pagination_size)
	end

	def get_order_items
		order_name = params[:order_name]
		order = get_order_by_name order_name
		current_date = Date.current
		order_date = Date.parse order.created_at
		days_passed = (current_date - order_date).to_i
		items = []
		if days_passed <= 45
			order.line_items.each do |item|
				items.push({
					:id => item.id,
					:title => item.name,
					:quantity => item.quantity,
					:price => item.price
				})
			end
		end
		render :json => items
	end

	def get_order_shipping
		order_name = params[:order_name]
		order = get_order_by_name order_name
		email = {:email => order.email}
		render :json => email.merge(order.shipping_address.attributes)
	end

	def create_refund
		order_name = '#' + params[:refund][:order_number].to_s
		order = get_order_by_name order_name
		refund_data = refund_params.merge({:order_id => order.id})
		if Refund.exists?(order_id: order.id)
			puts "Refund request already exists."
			render layout: false, content_type: 'application/liquid'
		else
			puts 'Creating Refund request...'
			@refund = Refund.new(refund_data)		
			@refund.save
			@progress = get_refund_progress @refund
			if @progress['financial'] == 'Complete' and @progress['fulfillment'] == 'Complete' and @progress['label'] == 'Incomplete'
				@label = create_label @refund
				@refund.label_url = @label['label_download']['href']
				@refund.save
				email_label @refund, @label
				@refund.label_issued = "Complete"
				@refund.save
			end
			render layout: false, content_type: 'application/liquid'
		end
	end

end
