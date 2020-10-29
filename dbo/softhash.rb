class Hash
	def soft
		SoftHash[**self]   # Note that this bypasses SoftHash's initialize() method.
	end
end

class SoftHash < Hash

	def soft!
		@soft = true
		self
	end

	def soft?
		@soft = true unless defined? @soft    # Because we can't trust initialize
		@soft
	end

	def hard!
		@soft = false
		self
	end

	def hard?
		! soft?
	end

	def initialize hard: false
		@soft = ! hard
	end

	def [] key
		return super(key) if hard?
		return super(key) if has_key? key

		matches = []

		keys.each do |k2|
			ksmall, k2small = key.to_s.downcase, k2.to_s.downcase
			return super(k2) if ksmall == k2small
			matches << k2 if k2small =~ /^#{ksmall}/
		end

		if matches.empty?
			keys.each do |k2|
				ksmall, k2small = key.to_s.downcase, k2.to_s.downcase
				matches << k2 if k2small =~ /#{ksmall}/
			end
		end

		case matches.size
		when 1
			return super(matches.first)
		when 0
			return super(key)
		else
			raise KeyError, "\nMultiple partially-matching keys: " + matches * ', '
		end
	end

end
