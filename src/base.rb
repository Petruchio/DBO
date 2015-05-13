module DBO
	class Base
		def self.new_attr_reader( *list )
			attr_reader *list
		end
	end
end
