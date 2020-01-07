class Refund < ApplicationRecord

	def self.search(query)
		Refund.where(:order_number => query.to_s)
	end

end
