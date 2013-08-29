# -*- ruby -*-

$TESTING_MINIUNIT = true

require 'rubygems'
require 'hoe'

Hoe.add_include_dirs "../../minitest/4.7.5/lib"

require 'test/unit/testcase'

Hoe.plugin :perforce, :email # can't do minitest, so no seattlerb wrapper

Hoe.spec 'minitest_tu_shim' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  dependency "minitest", "~> 4.0"
end

# vim: syntax=ruby
