require 'pg'                         # Presently PostgreSQL only.
require 'forwardable'
require 'symbolize_keys_recursively'

module DBO
	class Base

		@debug = false
		@sql = {
		}

		attr_accessor :name, :sql

		class << self

			def all
				ObjectSpace.each_object(self).to_a
			end

			def new_attr_reader( *list )
				list.each do |m|
					meth = m.to_sym
					next if method_defined? meth
					puts %Q[Calling #{self}.send( :attr_reader, #{meth} )] if @debug
					self.send( :attr_reader, meth )
				end
			end

			def names
				all.map { |b| b.name }
			end

			extend Forwardable
			def_delegators "all", *(Array.instance_methods - Object.instance_methods)

			def [](name)
				all.find { |b| b.name == "#{name}" }
			end

			def get_sql *args
				ret = {}
				@sql.each do |k,v|
					ret[k] = v % args.first
				end
				ret
			end

		end

		def initialize( name:, **args )
			@name = name
			args.each do |k,v|
				next unless instance_variable_get("@#{k}").nil?
				instance_variable_set("@#{k}", v)
			end
		end

	end
end
