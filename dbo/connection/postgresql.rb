require 'pg'
require 'dbo/caddy/pgpass'

module DBO
	module Connection
		class PostgreSQL


			def initialize *name, **args

				# Fix:  should check to see if @pgpass is set, and act accordingly.
				@pgpass = DBO::Caddy::PGPass.new


				# Fix:  PG.connect takes an "options" argument we don't account
				# for if we're getting our values from pgpass.
				# There's also a tty argument for older versions of PostgreSQL,
				# but ignore that until it becomes an issue.

				name = name.uniq.reject { |n| n.nil? }
				arguments = (name.size > 0) ? @pgpass[name.first] : args

				@conn = PG.connect **arguments

			end

			# We're presently returning an array of hashes, each hash
			# representing a row.  This is wasteful, but momentarily
			# convenient.  We probably need a record type, with a header
			# containing the field names and types.  Then the records
			# themselves could simply be arrays (or a Record type,
			# based on an Array).

			@errors = {
				PG::UndefinedColumn => "Unknown column",
				PG::UndefinedTable  => "Unknown table",
				PG::SyntaxError     => "Syntax error"
			}

			def exec *args
				@conn.exec(*args).to_a
			end

			def bar
				'-' * 80 + "\n"
			end

			def fail error, message, sql
				warn "#{message}  SQL dump:", bar, sql, bar, error.message
				exit
			end


		end
	end
end
