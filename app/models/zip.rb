class zip

	def self.mongo_client
		Mongoid::Client.default
	end

	def self.collection
		self.mongo_client['zips']
	end

	def self.all(prototype={}, sort={:population => 1}, offset = 1, limit = 100)
		tmp = {}
		sort.each {|k,v|
			k = k.to_sym == :population ? :pop: k.to_sym
		}
end


