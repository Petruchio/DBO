require 'forwardable'

module DBO
	class Base

		@debug = false
		@sql = {
		}

		attr_accessor :name


		class << self

			def all
				ObjectSpace.each_object(self).to_a
			end

			def boolean_reader( s1, *syms )
				syms.unshift s1
				syms.each do |sym|
					meth = sym.to_sym
					return if method_defined? meth
					define_method(meth) { instance_variable_get("@#{meth}") == 't' }
				end
			end

			def int_reader( s1, *syms )
				syms.unshift s1
				syms.each do |sym|
					meth = sym.to_sym
					return if method_defined? meth
					puts %Q[Calling #{self}.send( :attr_reader, #{meth} )] if @debug
					define_method(meth) { instance_variable_get("@#{meth}").to_i }
				end
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

		end

		def initialize( *args )
			args = args.first || {}
			args.each do |k,v|
				next unless instance_variable_get("@#{k}").nil?
				instance_variable_set("@#{k}", v)
			end
		end

		private

			def self.sql
				@sql
			end

	end
end
