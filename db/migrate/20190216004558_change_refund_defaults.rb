class ChangeRefundDefaults < ActiveRecord::Migration[5.2]
  def change
  	change_column_default(:refunds, :label_issued, 'Incomplete')
  	change_column_default(:refunds, :items_returned, 'Incomplete')
  	change_column_default(:refunds, :payment_refunded, 'Incomplete')
  	change_column_default(:refunds, :refund_method, 'Primary')
  end
end
