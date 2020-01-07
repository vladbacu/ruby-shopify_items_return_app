require 'json'
require 'faraday'

class RefundsController < ShopifyApp::AuthenticatedController
	
	include LabelUtilities 

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

	def show
		@shop_url = ShopifyAPI::Shop.current.domain
		@id = params[:id]
		@refund = Refund.find(params[:id])
		@order = get_order @refund.order_id
		@progress = get_refund_progress @refund
	end

	def capture_payment
		refund = Refund.find(params[:id])
		ShopifyAPI::Transaction.find(:all, params: {order_id: refund.order_id}).each do |xact|
			if xact.kind == "authorization"
				ShopifyAPI::Transaction.create(
					:order_id => refund.order_id,
					:amount => xact.amount,
					:currency => 'USD',
					:kind => 'capture',
					:parent_id => xact.id
				)
			end
		end
		redirect_to refund_path(:id => refund.id)
	end

	def fulfill_order
		refund = Refund.find(params[:id])
		location = ShopifyAPI::Location.find(:all).first
		unless location.nil?
			fulfillment = ShopifyAPI::Fulfillment.create(
				:order_id => refund.order_id,
				:location_id => location.id,
				:notify_customer => true
			)
		end
		redirect_to refund_path(:id => refund.id)
	end

	def issue_label
		@refund = Refund.find(params[:id])	
		if (@refund.label_url.nil?)
			puts "Issuing label for Order: " + @refund.order_number
			@label = create_label @refund
			@refund.label_url = @label['label_download']['href']
			@refund.save
			email_label @refund, @label
			label_issued
		end
	end

	def label_issued
		@refund = Refund.find(params[:id])	
		@refund.label_issued = "Complete"
		@refund.save
		redirect_to refund_path(:id => @refund.id)
	end

	def items_returned
		@refund = Refund.find(params[:id])
		@refund.items_returned = "Complete"
		@refund.save
		redirect_to refund_path(:id => @refund.id)
	end

	def refund_payment
		@refund = Refund.find(params[:id])
		issue_refund @refund		
		@refund.payment_refunded = "Complete"
		@refund.save
		redirect_to refund_path(:id => @refund.id)
	end

	def change_refund_method
		@refund = Refund.find(params[:id])
		if @refund.refund_method == "Primary"
			@refund.refund_method = "Giftcard"
		elsif @refund.refund_method == "Giftcard"
			@refund.refund_method = "Primary"
		end
		@refund.save
		redirect_to refund_path(:id => @refund.id)
	end

	def manual_refund
		@refund = Refund.find(params[:id])
		@refund.payment_refunded = "Complete"
		@refund.save
		redirect_to refund_path(:id => @refund.id)
	end

	def clean_manual_requests
		refunds = Refund.where(:payment_refunded => "Incomplete")
		refunds.each do |refund| 
			order = get_order refund.order_id
			if order.financial_status.include? 'refund'
				refund.payment_refunded = "Complete"
				refund.save
			end
		end
	end

	private

		def get_order(order_id)
			begin
				order = ShopifyAPI::Order.find order_id
				return order
			rescue StandardError => e
				pp e
				return nil
			end
		end	

		def apply_filter(filter)
			if filter == 'in-progress'
				return Refund.where(:payment_refunded => 'Incomplete');
			elsif filter == 'complete'
				return Refund.where(:payment_refunded => 'Complete');
			elsif filter == 'all'
				return Refund.all
			end
		end

		def apply_search(search)
			pp search
			Refund.where(:order_number => search).or(Refund.where(:first_name => search)).or(Refund.where(:last_name => search))
		end

		def get_refund_progress refund
			progress = {}
			order = get_order refund.order_id

			financial = order.financial_status.downcase
			if financial.include?('pending') or financial.include?('authorized')
				progress['financial'] = 'Incomplete'
			else
				progress['financial'] = 'Complete'
			end 

			progress['fulfillment'] = 'Incomplete'
			unless order.fulfillment_status.blank?
				if order.fulfillment_status.downcase.include? 'fulfilled'
					progress['fulfillment'] = 'Complete'
				end
			end

			if refund.label_issued == "Complete"
				progress['label'] = 'Complete'
			else
				progress['label'] = 'Incomplete'
			end

			if refund.items_returned == "Complete"
				progress['items_returned'] = 'Complete'
			else
				progress['items_returned'] = 'Incomplete'
			end	

			if refund.payment_refunded == "Complete"
				progress['payment_refunded'] = 'Complete'
			else
				progress['payment_refunded'] = 'Incomplete'
			end

			return progress
		end

		def calc_refund(refund)
			requested_items = JSON.parse refund['items']

			refund_items = []
			order = get_order refund.order_id
			order.line_items.each do |item|
				requested_items.each do |requested_item|
					if requested_item['id'].to_s == item.id.to_s
						refund_items.push({
							line_item_id: item.id,
							quantity: requested_item['quantity'],
							restock_type: 'return'
						})
					end
				end
			end

			data = { :shipping => { :amount => 0 }, :refund_line_items => refund_items }
			pp 'Calculate Refund Data:'
			pp data
			ShopifyAPI::Refund.calculate(data, params: {order_id: order.id})
		end

		def issue_refund(refund)
			gift_amount = 0
			shipping_deducted = false
			calc = calc_refund refund

			pp 'Refund calculation:'
			pp calc

			transactions = calc.transactions
			transactions.each do |xact|
				xact.kind = 'refund'
				unless shipping_deducted
					if xact.amount.to_f > 8.95
						xact.amount = xact.amount.to_f - 8.95
					end
				end

				if refund.refund_method == "Giftcard"
					gift_amount += xact.amount.to_f
					xact.amount = 0
				end
			end

			order = get_order refund.order_id
			customer_id = order.customer.id
			unless customer_id.nil?
				ShopifyAPI::Refund.create(
					:order_id => refund.order_id,
					:shipping => calc.shipping,
					:refund_line_items => calc.refund_line_items,
					:transactions => transactions,
					:currency => "USD" 
				)

				if refund.refund_method == "Giftcard"
					giftcard = Faraday.new(
						:url => 'https://9f4c073fd71ce15cf7b1c36bda3b536f:5ffb4300cf38c0ae3f00333a5cb015e9@wallaroo-hat-company.myshopify.com/admin/gift_cards.json'
					)

					giftcard_data = {
						:gift_card => {
							:customer_id => customer_id,
							:initial_value => gift_amount
						}
					}

					response = giftcard.post '', giftcard_data 
					card = JSON.parse response.body
					refund.giftcard_id = card['gift_card']['id']
					refund.save
				end
			end
		end
end