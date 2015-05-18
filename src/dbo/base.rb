require 'forwardable'

module DBO
	class Base

		@debug = false

		attr_accessor :name

		def self.all
			ObjectSpace.each_object(self).to_a
		end

		def self.boolean_reader( s1, *syms )
			syms.unshift s1
			syms.each do |sym|
				meth = sym.to_sym
				return if method_defined? meth
				define_method(meth) { instance_variable_get("@#{meth}") == 't' }
			end
		end

		def self.int_reader( s1, *syms )
			syms.unshift s1
			syms.each do |sym|
				meth = sym.to_sym
				return if method_defined? meth
				puts %Q[Calling #{self}.send( :attr_reader, #{meth} )] if @debug
				define_method(meth) { instance_variable_get("@#{meth}").to_i }
			end
		end

		def self.new_attr_reader( *list )
			list.each do |m|
				meth = m.to_sym
				next if method_defined? meth
				puts %Q[Calling #{self}.send( :attr_reader, #{meth} )] if @debug
				self.send( :attr_reader, meth )
			end
		end

		def self.names
			all.map { |b| b.name }
		end

		class << self
			extend Forwardable
			def_delegators "all", *(Array.instance_methods - Object.instance_methods)
		end

		def self.[](name)
			all.find { |b| b.name == "#{name}" }
		end

		def initialize( *args )
			args = args.first || {}
			args.each { |k,v| instance_variable_set("@#{k}", v) }
		end

	end
end
