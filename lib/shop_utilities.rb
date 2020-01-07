module ShopUtilities

	def get_order(order_id)
		shop = Shop.find_by(shopify_domain: params[:shop])
		if shop
			shop.with_shopify_session do
				ShopifyAPI::Order.find order_id	
			end
		end
	end

	def get_order_by_name(order_name)
		shop = Shop.find_by(shopify_domain: params[:shop])
		if shop
			shop.with_shopify_session do
				ShopifyAPI::Order.find(:all, :params => {:name => order_name, :status => 'any'}).first
			end
		end
	end

end