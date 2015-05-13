require 'dbo/base'
require 'dbo/schema'
require 'pg'
require 'pp'

module DBO
	class Database < Base

		@instances = {}
		@schemata  = {}

		attr_reader  :schemata
		alias_method :schemas, :schemata

		def self.all
			@instances.values
		end

		def self.[](name)
			@instances[name]
		end

		def self.list
			@instances.keys
		end

		def connection
			@connection
		end

		def schema_names
			@schemata.map { |s| s.name }
		end

		def template?
			@datistemplate
		end

		def can_connect?
			@datallowconn
		end

		def connect
			@connection = PG.connect dbname: @name
		end

		def disconnect
			@connection.close
		end

		def initialize( user: ENV['user'], password: nil, database: 'template1')
			@name = database
		end

		def name
			@datname
		end

		def to_boolean(*vars)
			vars.each do |var|
				v = "@#{var}"
				instance_variable_set v, instance_variable_get(v) == 't'
			end
		end

		def to_i(*vars)
			vars.each do |var|
				v = "@#{var}"
				instance_variable_set v, instance_variable_get(v).to_i
			end
		end

		def analyze
			raise "Connections not allowed to #{name}" unless can_connect?
			connect
			@schemata = DBO::Schema.find(@connection)
			puts display
			@schemata.each { |s| s.analyze(@connection) }
			disconnect
		end

		def self.analyze
			all.each { |m| m.analyze if m.can_connect? }
		end

		def self.display
			all.map { |db| db.display } * "\n"
		end

		def display
			"db: #{name}"
		end

		def schemata
			connect
			ret = []
			sql = 'SELECT * FROM information_schema.schemata'
			@connection.exec( sql ) do |sch|
				sch.fields.each { |f| Schema.new_attr_reader f.to_sym }
				sch.each do |row|
					ret << Schema.new(database: self)
					row.each { |k,v| ret.last.instance_variable_set "@#{k}", v }
				end
			end
			ret
		end


		def self.find( user: ENV['user'], password: nil )
			@instances['template1'] ||= self.new(database: 'template1')
			t1  = @instances['template1']
			sql = "SELECT * FROM pg_database"
			t1.connect

			t1.connection.exec( sql ) do |db|
				db.fields.each { |f| attr_reader f.to_sym }
				db.each do |row|
					this = @instances[row['datname']] = self.new
					row.each { |k,v| this.instance_variable_set "@#{k}", v }
					this.to_boolean :datistemplate, :datallowconn
					this.to_i :datconnlimit, :encoding, :datdba, :dattablespace, :datlastsysoid
				end
			end

			t1.disconnect
		end

		self.find

	end
end
