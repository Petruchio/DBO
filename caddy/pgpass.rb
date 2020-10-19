require 'dbo/caddy/text'
require 'dbo/softhash'

module DBO
	module Caddy
		class PGPass < Text



# Check: If this regex is too restrictive (and it may be), it'll make mistakes.

			@@pgpass_regex = %r<
				(
					(?: (?: \w | [-_] )+ : ){4} \S+
		 		)
			>x



			def initialize *files
				super

				target = files.first || ENV['PGPASSFILE'] || (ENV['HOME'] + '/.pgpass')

				unless File.exist? target
					warn "$PGPASSFILE does not exist:  #{ENV['PGPASSFILE']}" if ENV['PGPASSFILE']
					return false
				end
				unless File.readable? target
					warn "Cannot read password file:  #{target}.  Check the permissions."
					return false
				end

				if DBO::Caddy::Text.valid_file? target
					target = File.open target
				else
					soft!
					entries  = File.open(target).grep @@pgpass_regex  # Fix: exclude comments
					return if entries.empty?
					target = []
					entries.each do |e|
						e =~ @@pgpass_regex
						host, port, database, user, password = *Regexp.last_match.to_s.split(/:/)
						key = "---> #{user}@#{host}:#{database}"
						target.push key, e.chomp
					end
				end

				read target
				each do |k,v|
					self[k] = {}
					v =~ @@pgpass_regex
					subkeys = %W( host port database user password ).map { |key| key.to_sym }
				 	subvals = *Regexp.last_match.to_s.split(/:/)
					subkeys.each do |sk|
						self[k][sk.to_sym] = subvals.shift
					end
					self[k][:port] = self[k][:port].to_i
				end
			end



		end
	end
end
