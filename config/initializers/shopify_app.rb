ShopifyApp.configure do |config|
	if Rails.env == 'production'
		puts "Starting Shopify app in production mode."
		# Production configuration
		config.application_name = "Chelsea and Rachel: Returns"
		config.api_key = "849f4fb7881bb53b603cc06ceb5c0e81"
		config.secret = "a04012f29dfd9d32f03459a98d72f18b"
		config.scope = "read_products, read_orders,read_all_orders, write_orders, read_customers, read_themes, write_themes, read_gift_cards, write_gift_cards"
		config.api_version = "2019-10"
		config.embedded_app = true
		config.after_authenticate_job = false
		config.session_repository = Shop
	else
		puts "Starting Shopify app in development mode."
		# Development configuration
		config.application_name = "Chelsea and Rachel: Returns (DEV)"
		# Chelsea
		#config.api_key = "2d105bfaf39b9f273ead1ce897a129fd"
		#config.secret = "55aeb4b1ed2f82aa91cc90b5d4ef4208"
		
		#MAZEN
		config.api_key = "940a8be69f67dd2638eb3e36c0826498"
		config.secret = "20e2ea94d02217d276fe3ceb743ad8a9"
		config.scope = "read_products, read_orders, write_orders, read_customers, read_themes, write_themes, read_gift_cards, write_gift_cards" 
		config.api_version = "2019-10"
		config.embedded_app = true
		config.after_authenticate_job = false
		config.session_repository = Shop
	end
end


# ShopifyApp::Utils.fetch_known_api_versions                        # Uncomment to fetch known api versions from shopify servers on boot
# ShopifyAPI::ApiVersion.version_lookup_mode = :raise_on_unknown    # Uncomment to raise an error if attempting to use an api version that was not previously known
