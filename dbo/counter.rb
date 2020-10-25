#!/usr/bin/env ruby



module DBO
	class Counter
		def initialize
			reset
			@t1 = Time.now
			@last_report = nil
		end
		def reset
			@i = 0
		end
		def to_s
			@i += 1
			return '.' unless @i % 10 == 0
			return "%-4i %22s\n" % [ @i, elapsed_time_if_new ]
		end
		def elapsed_seconds
			Time.now - @t1
		end
		def elapsed_time
			format_time(elapsed_seconds)
		end
		def elapsed_time_if_new
			old = @last_report
			@last_report = new = elapsed_time
			return '' if old == new
			format_time(elapsed_seconds)
		end
		def start_time
			@t1
		end
		def format_time t
			base  = Time.new(0) + t
			units = [ :day, :hour, :min, :sec ]
			parts = units.map { |u| [u, base.send(u)] }.to_h
			parts[:day] -= 1
			ret = "%i:%02i:%02i:%02i elapsed" % parts.values
			ret.sub /^0:(?:00:)(?:0)?/, ''
		end
	end
end
