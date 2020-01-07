class AddItemsToRefund < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :items, :string
  end
end
