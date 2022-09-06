require 'minitest'
require "rake/testtask"

tmp  = __dir__  + '/tmp'
test = __dir__  + '/test'
lib  = __dir__  + '/lib'

Rake::TestTask.new do |t|
	t.libs << lib
	t.test_files = FileList['test/test*.rb']
	t.verbose = false
end
desc "Run tests"

task default: :test

__END__

$:.unshift lib
