require './app'
require 'rack/parser'

use Rack::Parser
use Rack::MethodOverride
run App
