# -*- ruby -*-

$TESTING_MINIUNIT = true

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs "../../minitest/dev/lib", "lib"

require 'test/unit/testcase'

Hoe.plugin :perforce, :email # can't do minitest, so no seattlerb wrapper

Hoe.spec 'minitest_tu_shim' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.rubyforge_name = "bfts"

  extra_deps << ['minitest', ">= #{MiniTest::Unit::VERSION}"]
end

# vim: syntax=ruby
