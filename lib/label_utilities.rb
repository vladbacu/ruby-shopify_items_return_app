module LabelUtilities

	def create_label refund
		ship_engine = Faraday.new(
			:url => 'https://api.shipengine.com/v1/',
			:headers => {
				'Content-Type' => 'application/json',
				'api-key' => 'D2y7DYTrv8xK0FMfTVyDyLcCVD5qg6FTXjWDhUEGhs0',
				'accept' => 'application/json'
			}
			)

		order = get_order refund.order_id
		order_grams = 0
		order.line_items.each do |item|
			if item.grams
				order_grams += item.grams.to_i
			end
		end

		test_label = true
		if Rails.env == 'production'
			test_label = false
		end	

		label_data = {
			:shipment => {
				:carrier_id => "se-132289",
				:service_code => "fedex_ground",
				:ship_to => {
					:name => "Wallaroo Hat Company",
					:phone => "1303494-5949",
					:address_line1 => "3155 Sterling Circle, Boulder, CO",
					:city_locality => "Boulder",
					:state_province => "CO",
					:postal_code => "80301",
					:country_code => "US",
					:address_residential_indicator => "No"	
				},
				:ship_from => {
					:name => refund.first_name + refund.last_name,
					:phone => refund.phone_number,
					:address_line1 => refund.address_1,
					:address_line2 => refund.address_2,
					:city_locality => refund.city,
					:state_province => refund.state,
					:postal_code => refund.postal_code,
					:country_code => "US",
					:address_residential_indicator => "Yes"	
				},
				:packages => [{
					# :package_code => 'small_flat_rate_box',
					:weight => {
						:value => order_grams,
						:unit => "gram"
					},
					:dimensions => {
						:unit => "inch",
						:length => "14.0",
						:width => "12.0",
						:height => "6.0"
					}
				}]
			},
			:test_label => test_label,
			:is_return_label => false
		}.to_json

		label_res = ship_engine.post 'labels', label_data
		pp label_res
		label = JSON.parse label_res.body
	end

	def email_label(refund, label)
		klaviyo = Faraday.new(:url => 'https://a.klaviyo.com/api/v1/email-template/LqdHsx/')
		email_data = {
			:api_key => 'pk_d33397d3a33d77a324956d0dfae7552d28',
			:from_email => 'info@wallaroohats.com',
			:from_name => 'Stephanie Carter',
			:to => refund['email'],
			:subject => 'Your Wallaroo return label is ready!',
			:context => {:label_url => label['label_download']['href']}.to_json
		}
		template = klaviyo.post 'send', email_data
	end
end