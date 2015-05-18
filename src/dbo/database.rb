lib = File.expand_path( File.dirname(__FILE__) + '/../../src' )
$:.unshift(lib) unless $:.include?(lib)

require 'dbo/base'

module DBO
	class Database < Base

		@schemata  = {}

		attr_reader    :schemata,      :connection
		boolean_reader :datistemplate, :datallowconn
		int_reader     :datconnlimit,  :encoding, :datdba, :dattablespace, :datlastsysoid

		alias_method :schemas,      :schemata
		alias_method :template?,    :datistemplate
		alias_method :can_connect?, :datallowconn

		def name
			datname
		end

		def connect!
			@connection = PG.connect dbname: name
		end

		def disconnect!
			return unless @connection.kind_of? PG::Connection
			@connection.close
		end

		def schema_names
			@schemata.map { |s| s.name }
		end

		def self.display
			all.map { |db| db.display } * "\n"
		end

		def display
			"db: #{name}"
		end

	end
end
