$: << File.expand_path( File.dirname(__FILE__) + '/../src' )

require 'dbo/sql'


module DBO

	module SQLManager
		@sql = {
		}

		def self.included base
			base.send :include, InstanceMethods
			base.extend ClassMethods
		end

		attr_reader :sql


		module InstanceMethods

			def set_sql
				var_names = self.class.get_sql_vars
				var_hash  = {}
				@sql      = {}

				var_names.each do |v|
					var_hash[v] = instance_variable_get("@#{v}")
				end
				self.class.sql.each { |k,v| @sql[k] = v % var_hash }

			end

			def initialize
				set_sql
			end

		end

		module ClassMethods

			attr_reader :sql

			def get_sql_vars
				@sql.values.map { |v| get_format_vars v }.flatten.uniq
			end

			def get_format_vars(str)
				ret = {}
				while true
					begin
						str % ret
						return ret.keys
					rescue KeyError
						ret[ "#{$!}".scan(/^key\{(.+)\}/).first.first.to_sym ] = '.'
					end
				end
			end

		end

	end


	class Base
		include SQLManager
	end


	class Foo < Base

		@sql = {
			x: "SELECT %{a} FROM %{b};",
			y: "SELECT %{c} FROM %{b};",
			z: "SELECT %{b} FROM %{d};"
		}

		def initialize(a:, b:, c:, d:)
			@a = a
			@b = b
			@c = c
			@d = d
			set_sql
		end

	end

end
