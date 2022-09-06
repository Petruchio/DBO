module DBO

	class Logger

		attr_accessor :level

		def initialize
			@level = 0  # Off by default
		end

		def debug
			level > 0
		end

		# Only one log level presently implemented.

		def log message
			return unless debug
			puts message
		end

	end
end
