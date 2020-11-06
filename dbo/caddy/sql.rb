require 'dbo/caddy/template'


module DBO
	module Caddy
		class SQL < Template

			attr_accessor :database   # Multiple database handles would be useful

			def initialize *file, database: nil  # Should handle connection?
				@database = database
				super(*file)
			end

			def default=
				raise "The default= method is not yet implemented."
			end

			def use_and_print key, **args
				use key, **args
			end

			def use key, **args
				raise "No database set." unless @database
				args.transform_keys! { |k| k.to_sym }
				sql = render(key, **args)
				@database.exec sql
			end

			def chain *queries, **args
				return if queries.empty?
				raise "No database set." unless @database
				# Fix: probably should check for all queries before starting
				args.transform_keys! { |k| k.to_sym }

				ret = []
				queries.each do |q|
					ret << use(q, **args)
				end
			end

			private

				def _chain
				end

<<COMMENT
			def try_chain *keys, *args
				raise "No database set." unless @database
				args.transform_keys! { |k| k.to_sym }
				sql = render(key, **args)
				@database.exec sql
			end

			def try_width_first *keys, **args
				ret = []
				try(key_1, **args).each do |hash|
					try(key_2, **hash)
				end
			end

			def try_depth_first *keys, **args
				try(key_1, **args).each do |hash|
					try(key_2, **hash)
				end
			end
COMMENT

		end
	end
end
