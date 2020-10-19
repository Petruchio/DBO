require 'fileutils'

def ls
	Dir.new(FileUtils.pwd).children.reject { |c| c =~ /^\./ }
end

def sql
	ls.grep /\.sql$/
end

def dirs
	ls.select { |f| File.directory? f }
end

def files
	ls.select { |f| File.file? f }
end

FileUtils.cd __dir__

def walk ind: 0
	sql.each  { |s| print ' ' * ind; puts s }
	dirs.each do |d|
		sleep 1
		FileUtils.cd d
		walk ind: ind + 2
	end
	FileUtils.cd '..'
end

walk

__END__
def dirs
	d = Dir(__dir__)
	d.children
end

puts dirs

__END__

module DBO
	module SQL
		extend FileUtils
		cd __dir__
		puts pwd
		def dirs
			Dir.entries(pwd).exclude
				grep { |f| File.directory?
				|entry| File.directory? File.join('/your_dir',entry) and !(entry =='.' || entry == '..') }
	end
end


