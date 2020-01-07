class ChangePaymentRefundedType < ActiveRecord::Migration[5.2]
  def change
  	change_column :refunds, :payment_refunded, :string
  	change_column_default(:refunds, :payment_refunded, 'Incomplete')
  end
end
