require 'yaml'

etc = __dir__ + '/../../etc/'
var = __dir__ + '/../../var/'

config = YAML::parse_file(etc + 'config.yaml').to_ruby


puts config.keys
