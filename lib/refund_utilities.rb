module RefundUtilities

	def refund_params
		params.require(:refund).permit(
			:order_number,
			:refund_method,
			:email,
			:first_name,
			:last_name,
			:address_1,
			:address_2,
			:city,
			:state,
			:postal_code,
			:phone_number,
			:items,
			:reason
		)
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
end