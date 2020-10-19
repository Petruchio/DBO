require 'dbo/caddy/template'


module DBO
	module Caddy
		class SQL < Template

			def initialize *file, database: nil
				super(*file)
			end

			def connect
			end

			def default=
				raise "The default= method is not yet implemented."
			end

		end
	end
end
