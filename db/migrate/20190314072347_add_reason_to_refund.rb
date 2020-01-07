class AddReasonToRefund < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :reason, :string
  end
end
