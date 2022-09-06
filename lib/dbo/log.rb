require 'dbo/logger'

# The scheme with LOGGER here is questionable, but good enough for now.

module DBO
	module Log

		LOGGER = Logger.new

		def log_level num = nil
			return LOGGER.level unless num
			lvl = num.to_i
			                                # This bit should be improved.
			unless num.kind_of? Integer
				warn "Value passed as log-level was not an integer.  Using #{lvl}"
			end
			LOGGER.level = lvl
		end

		def debug?
			LOGGER.debug
		end

		def log message
			LOGGER.log message
		end

		def logger
			puts LOGGER
			LOGGER
		end

		def debug!
			LOGGER.level = 1
		end

		def debug state = :on
			if state == :toggle
				state = debug? ? :off : :on
			end
			if    state == :on
				debug!
			elsif state == :off
				log_level 0
			end
		end

	end
end
