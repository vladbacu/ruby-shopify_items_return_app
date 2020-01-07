class AddRequestFieldsToRefund < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :refund_method, :string
  	add_column :refunds, :first_name, :string
  	add_column :refunds, :last_name, :string
  	add_column :refunds, :email, :string
  	add_column :refunds, :address_1, :string
  	add_column :refunds, :address_2, :string
  	add_column :refunds, :city, :string
  	add_column :refunds, :state, :string
  	add_column :refunds, :postal_code, :string
  	add_column :refunds, :giftcard_id, :string
  end
end
