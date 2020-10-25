require 'dbo/caddy/text'

module DBO
	module Caddy
		class Template < Text

			attr_reader :default

			def default= key
				return @default = key if has_key?(key)
				raise "Attempted to set default to missing key:  #{key}."
			end

			def render key = @default, **args
				self[key] % args
			end

			alias :r :render

		end
	end
end
