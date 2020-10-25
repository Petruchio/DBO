module DBO
	module Reporter
		attr_accessor :loud
		@loud = true

		def be_quiet
			@loud = false
		end
		def be_loud
			@loud = true
		end

		def report *messages, n: true
			return unless @loud

			messages.each do |m|
				if n
					$stderr.puts  m
				else
					$stderr.print m
				end
			end
		end

	end
end
