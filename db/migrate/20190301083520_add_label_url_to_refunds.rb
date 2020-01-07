class AddLabelUrlToRefunds < ActiveRecord::Migration[5.2]
  def change
  	add_column :refunds, :label_url, :string
  end
end
