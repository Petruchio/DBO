require 'pg'
require 'pp'
require 'securerandom'
require 'sql-caddy'
require "anbt-sql-formatter/formatter"

module DBO
	module Connection
		class Redshift

			attr_accessor :schema, :cursors, :active_schema

			def initialize schema: 'brighthouse_financial'
				@schema = schema
				@cursors = []
				@sql = TextCaddy.read __dir__ + '/redshift/redshift.sql'
				read_pgpass
				connect
			end

			def default_database
				@known_databases.first
			end

			def read_pgpass
				target = ENV['HOME'] + '/.pgpass'
				@known_databases ||= []
				File.open(target).each do |line|
					line.sub! /#.*/, ''
					next unless line =~ /:/
					@known_databases << [:host, :port, :dbname, :user, :password].zip(line.split /:/).to_h
				end
				@known_databases.uniq!
			end

			def exec *args
				@conn.exec(*args).map { |row| row.values }
			end

			def connect **args
				unless args.has_key? :database     # Should be handled better.
					args = default_database
				end
				@conn = PG.connect(
					host:     'modco.channelmix.com',
					port:     5439,
					user:     'modco_reporting',
					dbname:   'modco',
					password: 'm3%2B0R#It2l'
				)
			end

			def go_get template, *args
				ret  = []
				sql  = @sql[template]
				sql %= args unless args.empty?

				@conn.exec( sql ) do |result|
					result.each do |row|
						ret << row
					end
				end

				ret
			end

			def cursor name:, query:
				go_get :cursor, name, query
				@cursors << name
				name
			end

			def schemata
				go_get( :schemata ).map { |r| r['nspname'] }
			end

			def views schema: false
				ret  = []
				sql  = @sql[:views]
				sql += " WHERE schemaname = '#{schema}'" if schema

				@conn.exec( sql ) do |result|
					result.each do |row|
						ret << row['schemaname'] + '.' + row['viewname']
					end
				end

				ret
			end

			def tables schema: false
				ret  = []
				sql  = @sql[:tables]
				sql += " WHERE schemaname = '#{schema}'" if schema

				@conn.exec( sql ) do |result|
					result.each do |row|
						ret << row['schemaname'] + '.' + row['tablename']
					end
				end
				ret
			end

			def rows schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
				go_get( :rows, schema, relation).first['count'].to_i
			end

			def relation_param args
				relation = args.values_at(:relation, :table, :view).compact
				if relation.empty?
					raise "\nMissing parameter:  must specify table, view, or relation name"
				elsif relation.length > 1
					raise "\nRedundant paramters:  specify table, view, or relation, but not more than one."
				end
				ret = relation.first
				warn "Warning: whitespace in relation name." if ret =~ /\s/
				ret
			end

			def reloid schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
				go_get( :reloid, relation, schema).first['oid'].to_i
			end

			# Note:  we should probably be checking to see if these entities exist,
			# before we try to get information about them.  As it is, a request for
			# a non-existent entity causes errors with unclear messages.

			def relattrs schema: @schema, **args
				if args.include? :view
					raise "\nThis function is for tables, not views."
				end
				relation = relation_param args
				oid = reloid relation: relation, schema: schema
				sql = @sql[:relattrs] % [oid]
				@conn.exec( sql ) do |result|
					result.each do |row|
						return row
					end
				end
			end

			def fields schema: @schema, **args
				view_colattrs( schema: schema, **args ).map { |r| r['attname'] }
			end

			def view_colattrs schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
				oid = reloid relation: relation, schema: schema
				go_get( :colattrs, oid )
			end

			def view_fields schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
				sql = (@sql[:select] + " LIMIT 1") % [schema, relation]
				# This doesn't work if there are 0 records
				@conn.exec( sql ) do |result|
					result.each do |row|
						return row.keys
					end
				end
			end

			def view_to_table_def schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
				cols = view_colattrs relation: relation, schema: schema
				defs = cols.map { |c| c["attname"] + ' ' + c["format_type"] } * ",\n\t\t\t"
				@sql[:create_table] % [ schema, relation, defs ]
			end

			def fetch_tsv schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
				sql  = @sql[:select] % [ schema, relation ]

				data = go_get( :select, schema, relation ).map { |row| row.values.map { |n| (n || '\N').gsub( /\n/, '\n' ).gsub( /\\$/, '\\\\\\' ) } }
				data.map { |row| row * "\t" } * "\n"
			end

			def open_cursor
				@cursor = "cursor_" + SecureRandom.uuid.gsub(/-/, "_")
				sql     = 'BEGIN ' + @cursor
				puts "***"
				puts sql
				sql     = 'BEGIN nuts;'
				puts @conn.exec( sql )
			end

			def close_cursor
				sql = 'END ' + @cursor
				puts "***"
				puts sql
				puts @conn.exec( sql )
			end

			def print_fetch_tsv schema: @schema, **args
				relation = relation_param args
				if relation =~ /\./
					schema, relation = relation.split /\./
				end
		#
		#		size = rows relation: schema + '.' + relation
		#		r = 0
		#		step = 10
		#		cursor = 'this_cursor'
		#
		#		sql = 'BEGIN work;'
		#		puts sql
		#		sql = (@sql[:cursor] + @sql[:select]) % [ cursor, schema, relation ]
		#		puts sql
		#
		#		open_cursor
		#		close_cursor
		#
		#		while r < size
		#			puts @sql[:next_n] % [ step, cursor ]
		#			r += step
		#		end
		#		sql = 'END work;'
		#		puts sql
		#		exit

				predicate = args[:where]
				if predicate
					data = go_get( :where, schema, relation, predicate ).each do |row|
						puts row.values.map { |n|
							(n || '\N').gsub( /\n/, '\n' ).gsub( /\\$/, '\\\\\\' )
						} * "\t"
					end
				else
					data = go_get( :select, schema, relation ).each do |row|
						puts row.values.map { |n|
							(n || '\N').gsub( /\n/, '\n' ).gsub( /\\$/, '\\\\\\' )
						} * "\t"
					end
				end
			end

			def get_months schema: @schema, view:, field: 'report_date'
				if view =~ /\./
					schema, relation = view.split /\./
				end
				sql = "select distinct left(%s,7) from %s order by %s" % [field, view, field]
				ret = []
				@conn.exec( sql ) do |result|
					result.each do |row|
						ret << row["left"]
					end
				end
				ret
			end

			def get_dates schema: @schema, view:, field: 'report_date'
				if view =~ /\./
					schema, relation = view.split /\./
				end
				sql = "select distinct %s from %s order by %s" % [field, view, field]
				ret = []
				@conn.exec( sql ) do |result|
					result.each do |row|
						ret << row[field]
					end
				end
				ret
			end

			def view_as_table schema: @schema, view:
				if view =~ /\./
					schema, relation = view.split /\./
				end
				out = [ view_to_table_def(view: view, schema: schema) ]
				out << '--'
				fields = view_fields view: view, schema: schema
				out << "COPY #{view} (%s) FROM stdin;" % [ fields * ', ']
				out << fetch_tsv(schema: schema, view: view)
				out << '\.'
				out * "\n"
			end

			def dump_view_as_table schema: @schema, view:
				if view =~ /\./
					schema, relation = view.split /\./
				end
				puts view_to_table_def(view: view, schema: schema)
				fields = view_fields view: view, schema: schema
				puts '--'
				puts "COPY #{view} (%s) FROM stdin;" % [ fields * ', ']
				print_fetch_tsv(schema: schema, view: view)
				puts '\.'
			end


			def dump_long_view_as_table schema: @schema, view:
				if view =~ /\./
					schema, relation = view.split /\./
				end
				dates =  get_dates view: view, field: 'insert_date'
				puts view_to_table_def(view: view, schema: schema)
				fields = view_fields view: view, schema: schema
				puts '--'
				puts "COPY #{view} (%s) FROM stdin;" % [ fields * ', ']
					dates.each do |date|
					warn "Processing #{date}."
					predicate = " date = '#{date}'"
					print_fetch_tsv(schema: schema, view: view, where: predicate)
				end
				puts '\.'
			end

			def view_def schema, view
				ret       = go_get(:view_def, schema, view).first['definition']
				rule      = AnbtSql::Rule.new
				formatter = AnbtSql::Formatter.new(rule)
				formatter.format(ret)
			end

			def fields schema: nil, relation:
			end

		end
	end
end
