class AddOrderNumberToRefund < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :order_number, :string
  end
end
