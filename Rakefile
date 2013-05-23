# -*- ruby -*-

# $TESTING_MINIUNIT = true

require "rubygems"
require "hoe"

Hoe.plugin :perforce, :email # can't do minitest, so no seattlerb wrapper
Hoe.plugin :isolate

Hoe.add_include_dirs "../../minitest/dev/lib"

Hoe.spec "minitest_tu_shim" do
  developer "Ryan Davis", "ryand-ruby@zenspider.com"

  dependency "minitest", "< 5"
end

# vim: syntax=ruby
