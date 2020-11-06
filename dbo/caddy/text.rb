require 'dbo/softhash'
require 'dbo/hash/queue'

module DBO
	module Caddy
		class Text < SoftHash
			include DBO::Hash::Queue

			attr_accessor :strip, :dense, :position, :orientation

			def self.valid_file? file
				f = new file
				! f.empty?
			end

			@@key_regex = %r{
				\s*
				(?:\#|//)*
				--->
				\s+
				((?:[-_@.:]|\w)+)
				\s*$
			}x

			def initialize *file, strip: false, dense: false, soft: false
				@position    = 0
				@orientation = :forward
				hard! unless soft
				@strip, @dense = strip, dense
				return if file.empty?
				file.each do |f|
					load f
				end
			end

			def load file
				read File.open(file)
			end

			def read source
				source = source.split("\n") if source.kind_of? String

				key = nil
				source.each do |line|
					if line =~ @@key_regex
						key = $1.to_sym
						store key, ''
						next
					end

					line.strip! if @strip
					next        if @dense && (line !~ /\S/)
					next        if key.nil?

					store key, self.values_at(key).first + line
				end

				self
			end

			# Fix:  This method_missing call is an old idea about
			# generating methods from data.  It should probably go,
			# but I haven't thought it through yet.

			def method_missing name, *args
				if respond_to? name
					send name, *args
				else
					super
				end
			end

			# N.B.  We offer some methods for cleaning up strings, here,
			# but they're poorly considered.  Improve this.

			def strip!
				each_value do |v|
					v.each_line { |l| l.strip! }
				end
			end

		end
	end
end
