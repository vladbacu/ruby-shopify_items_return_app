class CreateRefunds < ActiveRecord::Migration[5.2]
  def change
    create_table :refunds do |t|
      t.string :order_id

      t.timestamps
    end
  end
end
