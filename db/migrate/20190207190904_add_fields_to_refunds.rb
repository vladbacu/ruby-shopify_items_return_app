class AddFieldsToRefunds < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :label_issued, :string
    add_column :refunds, :items_returned, :string
    add_column :refunds, :payment_refunded, :boolean
  end
end
