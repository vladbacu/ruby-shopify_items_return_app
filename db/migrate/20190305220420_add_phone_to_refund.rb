class AddPhoneToRefund < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :phone_number, :string
  end
end
