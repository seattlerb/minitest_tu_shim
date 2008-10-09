# -*- ruby -*-

$TESTING_MINIUNIT = true

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs "../../minitest/dev/lib", "lib"

require 'test/unit/testcase'

Hoe.new('minitest_tu_shim', Test::Unit::TestCase::VERSION) do |shim|
  shim.rubyforge_name = "bfts"

  shim.developer('Ryan Davis', 'ryand-ruby@zenspider.com')
end

# vim: syntax=Ruby
