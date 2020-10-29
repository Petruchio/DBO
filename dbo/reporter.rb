module DBO
	module Reporter

		attr_accessor :loud
		@loud = true

		def be_quiet
			@loud = false
		end
		def be_loud
			@loud = true
		end

		def output style
			case style
			when :json
				alias print_records print_records_as_json
			when :csv
				alias print_records print_records_as_csv
			when :tsv
				alias print_records print_records_as_tsv
			end
		end


		def report *messages, n: true
			return unless @loud

			messages.each do |m|
				m += "\n" if n
				$stderr.print m
			end
		end

		def print_records_as_json records
			records.each do |record|
				puts record.to_json
			end
		end

		def print_records_as_csv records
			records.each do |r|
				puts r.values.to_csv
			end
		end

		def print_records_as_tsv records
			records.each do |r|
				puts r.values * "\t"
			end
		end

		def print_sql sql
			puts bar
			puts sql.strip
		end

		def bar
			'-' * 80 + "\n"
		end

		alias print_records print_records_as_tsv

	end
end
