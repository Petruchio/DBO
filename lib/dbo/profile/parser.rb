#-- While most of the code has been changed, at this point, this
#-- began with Ruby's Net::SSH::Config, which was very helpful.
#--
#-- https://github.com/net-ssh/net-ssh


module DBO

	module Internal
		module Profile



			# This internal class represents a Host
			# rule from the configuration file.

			class Host < Hash

				class << self
					def split_host_list list
						list.to_s.chomp.gsub(/,/, ' ').strip.split(/\s+/)
					end
				end

				attr_accessor :patterns

				def initialize list
					hosts = self.class.split_host_list list
					neg, pos = hosts.partition { |h| h.start_with?('!') }
					@patterns = {
						negative: neg.map { |h| pattern2regex(h[1..-1]) },
						positive: pos.map { |h| pattern2regex(h) }
					}
				end


				# This takes in a string, and returns a regular
				# expression to be used for matching Host keys.
				#
				# While DBO's profile config file format is modeled
				# after SSH's, it differs in how it handles patterns.
				# While SSH # expects a simple shell-style glob,
				# DBO::Profile takes full regular expressions.
				#
				# This uses Ruby's regular expresion # engine, Onigmo:
				#
				# https://github.com/k-takata/Onigmo
				#
				# The regex performs a full match; it will be anchored
				# to the beginning and end of the string being matched,
				# whether it's written that way or not.

				def pattern2regex(pattern)
					unless pattern[0]  == '^'
						pattern  = '^' + pattern
					end
					unless pattern[-1] == '$'
							pattern += '$'
					end

					Regexp.new(pattern)
				end


				def match? host
					if    @patterns[:positive].none? { |n| host =~ n }
						return false
					elsif @patterns[:negative].any?  { |n| host =~ n }
						return false
					else
						return true
					end
				end


				def apply_if_matches host
					return host unless match?(host)
					self.merge host
				end


				def apply host
					self.merge host
				end

			end



			class Match < Host

				@@keywords = %W( host user localuser all )

				def initialize(keyword, list)
					key = keyword.to_s.downcase
					unless @@keywords.include? key
						raise "Unsupported keyword: #{keyword}"
					end
				end

			end



		end
	end



	class Profile

		@@default_file = ENV['HOME'] + '/.dbo-profiles'

		@rules = [ DBO::Internal::Profile::Host.new('.*') ]

		def self.[](key)
			ret = @match.inject(global) { |old, new| new.apply_if_matches(old) }
			@host.each do |h|
				return h.apply(ret) if h.match? ret
			end
			ret
		end


		def self.load(filename)
			file = open_file filename
			lnum = 0

			file.each do |line|
				lnum += 1
				next if line =~ /^\s*(#|$)/

				# This ignores malformed lines.
				# It should probably raise an error instead.
				next unless (key, value = parseline line)

				if key == 'host'
					@rules << DBO::Internal::Profile::Host.new(value)
				elsif key == 'match'
					@rules << DBO::Internal::Profile::Match.new(value)
				else
					@rules.last[key] = value
				end
			end
		end


		private

		# This method tries to open a file, and raises
		# an error if it cannot.  If the file is not
		# specified, it will check the DBO_PROFILES
		# environment variable, and try to open the
		# file it specifies.  If DBO_PROFILES is not
		# defined, it will attempt to open '.dbo-profiles'
		# in the user's home directory.

		def open_file conf = false
			return File.open(conf) if conf
			conf = ENV['DBO_PROFILES']
			if conf
				if    ! File.exists? conf
					raise Errno::EACCES.new(
						'$DBO_PROFILES is defined, but the file indicated does not exist.'
					)
				elsif ! File.readable? conf
					raise Errno::EACCES.new(
						'$DBO_PROFILES is defined, but the file indicated is not readable.'
					)
				else
					return File.open(conf)
				end
				warn "$DBO_PROFILES=#{conf}"
				warn "Defaulting to #{@@default_file}"
			end
			return File.open(@@default_file)
		end


		# This method takes in a line of text, and tries to
		# interpret it as a key-value pair.  If successful,
		# it returns the key and value; if not, it returns nil.

		def parseline line
			return nil if line =~ /^\s*(#|$)/

			if line =~ /^\s*(\S+)\s*=(.*)$/
				key, value = $1, $2
			else
				key, value = line.strip.split(/\s+/, 2)
			end

			# It would be better to report the line number,
			# but I'm not dealing with that right now.
			if value.nil?
				raise 'Syntax error: ' + line
			end

			value = unquote(value)

			value = case value.strip
				when /^ \d+ $/x  then value.to_i
				when /^ no  $/ix then false
				when /^ yes $/ix then true
				else value
			end

			return key.downcase, value
		end


		# This method takes a string, and returns the same string
		# with the beginning and ending double-quote removed.  If
		# the string isn't double-quoted, it simply returns the
		# unaltered string.

		def unquote(string)
			string =~ /^\s*"(.*)"\s*$/ ? Regexp.last_match(1) : string
		end

	end
end
