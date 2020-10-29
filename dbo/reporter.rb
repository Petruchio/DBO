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

		def report *messages, n: true
			return unless @loud

			messages.each do |m|
				m += "\n" if n
				$stderr.print m
			end
		end

		def bar
			'-' * 80 + "\n"
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

		def print_values_as_sql records
			records.each do |r|
				puts bar
				puts r.strip
			end
		end

		alias print_records print_records_as_tsv

		def output style
			case style
			when :json
				alias print_records print_records_as_json
			when :csv
				alias print_records print_records_as_csv
			when :tsv
				alias print_records print_records_as_tsv
			when :sql
				alias print_records print_values_as_sql
			end
		end

	end
end
