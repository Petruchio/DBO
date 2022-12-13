module DBO
	def keywords_to_vars **args
		args.each do |k,v|
			instance_variable_set("@#{k}", v)
		end
	end

	def die message = false
		warn message if message
		exit 1
	end

	# Not yet working.

	refine File do
		def self.must_be file, *states
			raise 'Implement me.'
			if states.include? :readable
			end
		end
	end

	def bar char = '*', length: 80
		puts char.to_s * length
	end

	# Untested:

	def handle_defaults arguments = {}, **args
		@default = self.class.default
		arg      = @default.merge(arguments.merge args)
		keywords_to_vars(**arg)
	end

	# Not working properly.
	def warn message
		return unless @warnings
		Kernel.warn message
	end
end

__END__

# "Monkey patching is like violence:  if it
# isn't working, you aren't using enough of it."

class Object
	def keywords_to_vars **args
		args.each do |k,v|
			instance_variable_set("@#{k}", v)
		end
	end
end

# Less violent, doesn't work yet:

class Object
	if self.class.to_s.split(/::/).first == 'DBO'
		define_method('keywords_to_vars') do |**args|
			args.each do |k,v|
				instance_variable_set("@#{k}", v)
			end
		end
	end
end
