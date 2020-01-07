class Shop < ActiveRecord::Base
  include ShopifyApp::SessionStorage

  def with_shopify!
  	session = ShopifyAPI::Session.new(shopify_domain, shopify_token)
  	ShopifyAPI::Base.activate_session(session)
  end
  
  def api_version
    ShopifyApp.configuration.api_version
  end

end
