require 'rake/testtask'

dir  = File.expand_path File.dirname(__FILE__)
tmp  = dir  + '/tmp'
test = dir  + '/test'
lib  = dir  + '/src'

$:.unshift "#{dir}/src"

Rake::TestTask.new do |t|
	t.libs << lib
	t.test_files = FileList['test/test*.rb']
	t.verbose = false
end
