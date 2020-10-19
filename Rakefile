require 'rake/testtask'

Rake::TestTask.new do |t|
	t.pattern = "test/*.rb"
end

task default: [:test]

__END__

test = "#{__dir__}/test/template-caddy.t"

task :roc do |t|
	puts system("roc #{test} 'ruby #{test}'")
end
