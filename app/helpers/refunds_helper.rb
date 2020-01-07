module RefundsHelper

	def show_svg(path)
	  File.open("app/assets/images/#{path}", "rb") do |file|
	    raw file.read
	  end
	end	

	def get_item_image_url(product_id, variant_id)
		begin
			images = ShopifyAPI::Image.find(:all, :params => {:product_id => product_id})
			images.each do |image|
				if (image.variant_ids.include? variant_id)
					return image.src
				end
			end
			return ''
		rescue
			puts 'Failed to retrieve an image for product.' 
			return ''
		end
	end

	def get_pagination()
		puts 'Getting pagination...'
		@refund_requests = []
	end
end
