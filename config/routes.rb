Rails.application.routes.draw do
  root :to => 'refunds#index'
  mount ShopifyApp::Engine, at: '/'

  post 'app_proxy/create_refund' => 'app_proxy#create_refund'
  post 'app_proxy/get_order_items' => 'app_proxy#get_order_items' 
  post 'app_proxy/get_order_shipping' => 'app_proxy#get_order_shipping' 

  resources :refunds
  get 'refunds/capture_payment/:id' => 'refunds#capture_payment', :as => :refund_capture
  get 'refunds/fulfill_order/:id' => 'refunds#fulfill_order', :as => :refund_fulfill
  get 'refunds/issue_label/:id' => 'refunds#issue_label', :as => :refund_issue_label
  get 'refunds/label_issued/:id' => 'refunds#label_issued', :as => :refund_label
  get 'refunds/items_returned/:id' => 'refunds#items_returned', :as => :refund_items
  get 'refunds/refund_payment/:id' => 'refunds#refund_payment', :as => :refund_payment
  get 'refunds/refund_payment_change/:id' => 'refunds#change_refund_method', :as => :refund_payment_change
  get 'refunds/manual_refund/:id' => 'refunds#manual_refund', :as => :refund_manual_payment

end
