require 'dbo/base'
module DBO


	class SQL < String

		alias_method :>>, :%

		class << self
			def [](string)
				self.new string
			end

			alias_method :|, :[]
		end

		def format_vars
			ret = {}
			while true
				begin
					self >> ret
					return ret.keys
				rescue KeyError
					ret[ "#{$!}".scan(/^key\{(.+)\}/).first.first.to_sym ] = '.'
				end
			end
		end

		def % hash
			defaults = Hash[ format_vars.zip format_vars.map { |v| "\%{#{v}}" } ]
			self >> defaults.merge(hash)
		end

	end


end
