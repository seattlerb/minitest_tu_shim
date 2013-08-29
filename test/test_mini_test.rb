require 'stringio'
require 'minitest/autorun'
require 'test/unit'

class TestMiniTest < Minitest::Test
  def setup
    srand 42
    MiniTest::Unit::TestCase.reset
    @tu = MiniTest::Unit.new
    @output = StringIO.new("")
  end

  def teardown
    # MiniTest::Unit.output = $stdout
    Object.send :remove_const, :ATestCase if defined? ATestCase
  end

  BT_MIDDLE = ["./lib/mini/test.rb:165:in `run_test_suites'",
               "./lib/mini/test.rb:161:in `each'",
               "./lib/mini/test.rb:161:in `run_test_suites'",
               "./lib/mini/test.rb:158:in `each'",
               "./lib/mini/test.rb:158:in `run_test_suites'",
               "./lib/mini/test.rb:139:in `run'",
               "./lib/mini/test.rb:106:in `run'"]

  def util_expand_bt bt
    if RUBY_VERSION =~ /^1\.9/ then
      bt.map { |f| (f =~ /^\./) ? File.expand_path(f) : f }
    else
      bt
    end
  end

  def test_filter_backtrace_all_unit
    bt = (["./lib/mini/test.rb:165:in `__send__'"] +
          BT_MIDDLE +
          ["./lib/mini/test.rb:29"])
    ex = bt.clone
    fu = MiniTest::filter_backtrace(bt)
    assert_equal ex, fu
  end

  attr_accessor :reporter

  def run_tu_with_fresh_reporter flags = %w[--seed 42]
    options = Minitest.process_args flags

    @output = StringIO.new("")
    self.reporter = Minitest::CompositeReporter.new
    reporter << Minitest::SummaryReporter.new(@output, options)
    reporter << Minitest::ProgressReporter.new(@output, options)

    reporter.start

    @tus ||= [@tu]
    @tus.each do |tu|
      Minitest::Runnable.runnables.delete tu

      tu.run reporter, options
    end

    reporter.report
  end

  def test_run_failing # TODO: add error test
    tc = Class.new Test::Unit::TestCase do
      def self.test_order
        :alpha
      end

      def test_something
        assert true
      end

      def test_failure
        assert false
      end
    end

    Object.const_set(:ATestCase, tc)

    @tu = tc
    run_tu_with_fresh_reporter

    expected = "Run options:

# Running:

F.

Finished in 0.00s, 0.00 runs/s, 0.00 assertions/s.

  1) Failure:
ATestCase#test_failure [FILE:LINE]:
Failed assertion, no message given.

2 runs, 2 assertions, 1 failures, 0 errors, 0 skips
"
    assert_report expected
  end

  def test_run_error
    tc = Class.new Test::Unit::TestCase do
      def self.test_order
        :alpha
      end

      def test_something
        assert true
      end

      def test_error
        raise "unhandled exception"
      end
    end

    Object.const_set(:ATestCase, tc)

    @tu = tc
    run_tu_with_fresh_reporter

    expected = "Run options:

# Running:

E.

Finished in 0.00s, 0.00 runs/s, 0.00 assertions/s.

  1) Error:
ATestCase#test_error:
RuntimeError: unhandled exception
    FILE:LINE:in `test_error'

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
"
    assert_report expected
  end

  def test_run_error_teardown
    tc = Class.new Test::Unit::TestCase do
      def test_something
        assert true
      end

      def teardown
        raise "unhandled exception"
      end
    end

    Object.const_set(:ATestCase, tc)

    @tu = tc
    run_tu_with_fresh_reporter

    expected = "Run options:

# Running:

E

Finished in 0.00s, 0.00 runs/s, 0.00 assertions/s.

  1) Error:
ATestCase#test_something:
RuntimeError: unhandled exception
    FILE:LINE:in `teardown'

1 runs, 1 assertions, 0 failures, 1 errors, 0 skips
"
    assert_report expected
  end

  def test_run_skip
    tc = Class.new Test::Unit::TestCase do
      def self.test_order
        :alpha
      end

      def test_something
        assert true
      end

      def test_skip
        skip "not yet"
      end
    end

    Object.const_set(:ATestCase, tc)

    @tu = tc
    run_tu_with_fresh_reporter %w[--seed 42 --verbose]

    expected = "Run options:

# Running:

ATestCase#test_skip = 0.00 s = S
ATestCase#test_something = 0.00 s = .

Finished in 0.00s, 0.00 runs/s, 0.00 assertions/s.

  1) Skipped:
ATestCase#test_skip [FILE:LINE]:
not yet

2 runs, 1 assertions, 0 failures, 0 errors, 1 skips
"
    assert_report expected
  end

  def assert_report expected = nil
    expected ||= "Run options:

# Running:

.

Finished in 0.00s, 0.00 runs/s, 0.00 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
"
    output = @output.string.gsub(/\d+\.\d+/, "0.00")
    output.sub!(/Loaded suite .*/, 'Loaded suite blah')
    output.sub!(/[\w\/\.]+:\d+/, 'FILE:LINE')
    output.gsub!(/(Run options:).+/, '\1')
    assert_equal(expected, output)
  end

  def test_run_failing_filtered
    tc = Class.new Test::Unit::TestCase do
      def self.test_order
        :alpha
      end

      def test_something
        assert true
      end

      def test_failure
        assert false
      end
    end

    Object.const_set(:ATestCase, tc)

    @tu = tc
    run_tu_with_fresh_reporter %w(-n /something/)

    assert_report
  end

  def test_run_passing
    tc = Class.new Test::Unit::TestCase do
      def test_something
        assert true
      end
    end

    Object.const_set(:ATestCase, tc)

    @tu = tc
    run_tu_with_fresh_reporter

    assert_report
  end
end

class TestMiniTestTestCase < Minitest::Test
  def setup
    MiniTest::Unit::TestCase.reset

    @tc = MiniTest::Unit::TestCase.new 'fake tc'
    @zomg = "zomg ponies!"
    @assertion_count = 1
  end

  def teardown
    assert_equal(@assertion_count, @tc.assertions,
                 "expected #{@assertion_count} assertions to be fired during the test, not #{@tc.assertions}") if @tc.assertions
    Object.send :remove_const, :ATestCase if defined? ATestCase
  end

  def test_class_inherited
    @assertion_count = 0

    testcase = Class.new Test::Unit::TestCase

    assert_includes Minitest::Runnable.runnables, testcase
  end

  def test_class_asserts_match_refutes
    @assertion_count = 0

    methods = MiniTest::Assertions.public_instance_methods
    methods.map! { |m| m.to_s } if Symbol === methods.first

    ignores = %w(assert_no_match assert_not_equal
                 assert_not_nil assert_not_same assert_nothing_thrown
                 assert_output assert_raise assert_nothing_raised
                 assert_raises assert_throws assert_send
                 assert_silent assert_block)
    asserts = methods.grep(/^assert/).sort - ignores
    refutes = methods.grep(/^refute/).sort - ignores

    assert_empty refutes.map { |n| n.sub(/^refute/, 'assert') } - asserts
    assert_empty asserts.map { |n| n.sub(/^assert/, 'refute') } - refutes
  end

  def test_assert
    @assertion_count = 2

    @tc.assert_equal true, @tc.assert(true), "returns true on success"
  end

  def test_assert__triggered
    util_assert_triggered "Failed assertion, no message given." do
      @tc.assert false
    end
  end

  def test_assert__triggered_message
    util_assert_triggered @zomg do
      @tc.assert false, @zomg
    end
  end

  def test_assert_empty
    @assertion_count = 2

    @tc.assert_empty []
  end

  def test_assert_empty_triggered
    @assertion_count = 2

    util_assert_triggered "Expected [1] to be empty." do
      @tc.assert_empty [1]
    end
  end

  def test_assert_equal
    @tc.assert_equal 1, 1
  end

  def test_assert_equal_different
    util_assert_triggered "Expected: 1\n  Actual: 2" do
      @tc.assert_equal 1, 2
    end
  end

  def test_assert_in_delta
    @tc.assert_in_delta 0.0, 1.0 / 1000, 0.1
  end

  def test_assert_in_delta_triggered
    util_assert_triggered 'Expected |0.0 - 0.001| (0.001) to be <= 1.0e-06.' do
      @tc.assert_in_delta 0.0, 1.0 / 1000, 0.000001
    end
  end

  def test_assert_in_epsilon
    @assertion_count = 8

    @tc.assert_in_epsilon 10000, 9991
    @tc.assert_in_epsilon 9991, 10000
    @tc.assert_in_epsilon 1.0, 1.001
    @tc.assert_in_epsilon 1.001, 1.0

    @tc.assert_in_epsilon 10000, 9999.1, 0.0001
    @tc.assert_in_epsilon 9999.1, 10000, 0.0001
    @tc.assert_in_epsilon 1.0, 1.0001, 0.0001
    @tc.assert_in_epsilon 1.0001, 1.0, 0.0001
  end

  def test_assert_in_epsilon_triggered
    util_assert_triggered 'Expected |10000 - 9990| (10) to be <= 9.99.' do
      @tc.assert_in_epsilon 10000, 9990
    end
  end

  def test_assert_includes
    @assertion_count = 2

    @tc.assert_includes [true], true
  end

  def test_assert_includes_triggered
    @assertion_count = 3

    e = @tc.assert_raises MiniTest::Assertion do
      @tc.assert_includes [true], false
    end

    expected = "Expected [true] to include false."
    assert_equal expected, e.message
  end

  def test_assert_instance_of
    @tc.assert_instance_of String, "blah"
  end

  def test_assert_instance_of_triggered
    util_assert_triggered 'Expected "blah" to be an instance of Array, not String.' do
      @tc.assert_instance_of Array, "blah"
    end
  end

  def test_assert_kind_of
    @tc.assert_kind_of String, "blah"
  end

  def test_assert_kind_of_triggered
    util_assert_triggered 'Expected "blah" to be a kind of Array, not String.' do
      @tc.assert_kind_of Array, "blah"
    end
  end

  def test_assert_match
    @assertion_count = 2
    @tc.assert_match(/\w+/, "blah blah blah")
  end

  def test_assert_match_triggered
    @assertion_count = 2
    util_assert_triggered 'Expected /\d+/ to match "blah blah blah".' do
      @tc.assert_match(/\d+/, "blah blah blah")
    end
  end

  def test_assert_nil
    @tc.assert_nil nil
  end

  def test_assert_nil_triggered
    util_assert_triggered 'Expected 42 to be nil.' do
      @tc.assert_nil 42
    end
  end

  def test_assert_operator
    @tc.assert_operator 2, :>, 1
  end

  def test_assert_operator_triggered
    util_assert_triggered "Expected 2 to be < 1." do
      @tc.assert_operator 2, :<, 1
    end
  end

  def test_assert_raises
    @tc.assert_raises RuntimeError do
      raise "blah"
    end
  end

  def test_assert_raises_triggered_different
    e = assert_raises MiniTest::Assertion do
      @tc.assert_raises RuntimeError do
        raise SyntaxError, "icky"
      end
    end

    expected = "[RuntimeError] exception expected, not
Class: <SyntaxError>
Message: <\"icky\">
---Backtrace---
FILE:LINE:in `test_assert_raises_triggered_different'
---------------"

    actual = e.message.
      gsub(/[\w\/\.]+:\d+/, 'FILE:LINE').
      gsub(/block .\d+ levels. in /, '')

    assert_equal expected, actual
  end

  def test_assert_raises_triggered_none
    e = assert_raises Minitest::Assertion do
      @tc.assert_raises Minitest::Assertion do
        # do nothing
      end
    end

    expected = "Minitest::Assertion expected but nothing was raised."

    assert_equal expected, e.message
  end

  def test_assert_respond_to
    @tc.assert_respond_to "blah", :empty?
  end

  def test_assert_respond_to_triggered
    util_assert_triggered 'Expected "blah" (String) to respond to #rawr!.' do
      @tc.assert_respond_to "blah", :rawr!
    end
  end

  def test_assert_same
    @assertion_count = 3

    o = "blah"
    @tc.assert_same 1, 1
    @tc.assert_same :blah, :blah
    @tc.assert_same o, o
  end

  def test_assert_same_triggered
    util_assert_triggered 'Expected 2 (oid=N) to be the same as 1 (oid=N).' do
      @tc.assert_same 1, 2
    end
  end

  def test_assert_same_equal_triggered
    s1 = "blah"
    s2 = "blah"

    util_assert_triggered 'Expected "blah" (oid=N) to be the same as "blah" (oid=N).' do
      @tc.assert_same s1, s2
    end
  end

  def test_assert_send
    @tc.assert_send [1, :<, 2]
  end

  def test_assert_send_bad
    util_assert_triggered "Expected 1.>(*[2]) to return true." do
      @tc.assert_send [1, :>, 2]
    end
  end

  def test_assert_throws
    @tc.assert_throws(:blah) do
      throw :blah
    end
  end

  def test_assert_throws_different
    util_assert_triggered 'Expected :blah to have been thrown, not :not_blah.' do
      @tc.assert_throws(:blah) do
        throw :not_blah
      end
    end
  end

  def test_assert_throws_unthrown
    util_assert_triggered 'Expected :blah to have been thrown.' do
      @tc.assert_throws(:blah) do
        # do nothing
      end
    end
  end

  def test_capture_io
    @assertion_count = 0

    out, err = capture_io do
      puts 'hi'
      warn 'bye!'
    end

    assert_equal "hi\n", out
    assert_equal "bye!\n", err
  end

  def test_flunk
    util_assert_triggered 'Epic Fail!' do
      @tc.flunk
    end
  end

  def test_flunk_message
    util_assert_triggered @zomg do
      @tc.flunk @zomg
    end
  end

  def test_message
    @assertion_count = 0

    assert_equal "blah2.",         @tc.message { "blah2" }.call
    assert_equal "blah2.",         @tc.message("") { "blah2" }.call
    assert_equal "blah1.\nblah2.", @tc.message("blah1") { "blah2" }.call
  end

  def test_pass
    @tc.pass
  end

  def test_runnable_methods_sorted
    @assertion_count = 0

    sample_test_case = Class.new Test::Unit::TestCase do
      def self.test_order; :sorted; end
      def test_test3; assert "does not matter" end
      def test_test2; assert "does not matter" end
      def test_test1; assert "does not matter" end
    end

    expected = %w(test_test1 test_test2 test_test3)
    assert_equal expected, sample_test_case.runnable_methods
  end

  def test_runnable_methods_random
    @assertion_count = 0

    sample_test_case = Class.new Test::Unit::TestCase do
      def self.test_order; :random end
      def test_test1; assert "does not matter" end
      def test_test2; assert "does not matter" end
      def test_test3; assert "does not matter" end
    end

    srand 42
    expected = %w(test_test1 test_test2 test_test3)
    max = expected.size
    expected = expected.sort_by { rand(max) }

    srand 42
    result = sample_test_case.runnable_methods

    assert_equal expected, result
  end

  def test_refute
    @assertion_count = 2

    @tc.assert_equal false, @tc.refute(false), "returns false on success"
  end

  def test_refute_empty
    @assertion_count = 2

    @tc.refute_empty [1]
  end

  def test_refute_empty_triggered
    @assertion_count = 2

    util_assert_triggered "Expected [] to not be empty." do
      @tc.refute_empty []
    end
  end

  def test_refute_equal
    @tc.refute_equal "blah", "yay"
  end

  def test_refute_equal_triggered
    util_assert_triggered 'Expected "blah" to not be equal to "blah".' do
      @tc.refute_equal "blah", "blah"
    end
  end

  def test_refute_in_delta
    @tc.refute_in_delta 0.0, 1.0 / 1000, 0.000001
  end

  def test_refute_in_delta_triggered
    util_assert_triggered 'Expected |0.0 - 0.001| (0.001) to not be <= 0.1.' do
      @tc.refute_in_delta 0.0, 1.0 / 1000, 0.1
    end
  end

  def test_refute_in_epsilon
    @tc.refute_in_epsilon 10000, 9989
  end

  def test_refute_in_epsilon_triggered
    util_assert_triggered 'Expected |10000 - 9991| (9) to not be <= 10.0.' do
      @tc.refute_in_epsilon 10000, 9991
      fail
    end
  end

  def test_refute_includes
    @assertion_count = 2

    @tc.refute_includes [true], false
  end

  def test_refute_includes_triggered
    @assertion_count = 3

    e = @tc.assert_raises MiniTest::Assertion do
      @tc.refute_includes [true], true
    end

    expected = "Expected [true] to not include true."
    assert_equal expected, e.message
  end

  def test_refute_instance_of
    @tc.refute_instance_of Array, "blah"
  end

  def test_refute_instance_of_triggered
    util_assert_triggered 'Expected "blah" to not be an instance of String.' do
      @tc.refute_instance_of String, "blah"
    end
  end

  def test_refute_kind_of
    @tc.refute_kind_of Array, "blah"
  end

  def test_refute_kind_of_triggered
    util_assert_triggered 'Expected "blah" to not be a kind of String.' do
      @tc.refute_kind_of String, "blah"
    end
  end

  def test_refute_match
    @assertion_count = 2

    @tc.refute_match(/\d+/, "blah blah blah")
  end

  def test_refute_match_triggered
    @assertion_count = 2

    util_assert_triggered 'Expected /\w+/ to not match "blah blah blah".' do
      @tc.refute_match(/\w+/, "blah blah blah")
    end
  end

  def test_refute_nil
    @tc.refute_nil 42
  end

  def test_refute_nil_triggered
    util_assert_triggered 'Expected nil to not be nil.' do
      @tc.refute_nil nil
    end
  end

  def test_refute_operator
    @tc.refute_operator 2, :<, 1
  end

  def test_refute_operator_triggered
    util_assert_triggered "Expected 2 to not be > 1." do
      @tc.refute_operator 2, :>, 1
    end
  end

  def test_refute_respond_to
    @tc.refute_respond_to "blah", :rawr!
  end

  def test_refute_respond_to_triggered
    util_assert_triggered 'Expected "blah" to not respond to empty?.' do
      @tc.refute_respond_to "blah", :empty?
    end
  end

  def test_refute_same
    @tc.refute_same 1, 2
  end

  # TODO: "with id <id>" crap from assertions.rb
  def test_refute_same_triggered
    util_assert_triggered 'Expected 1 (oid=N) to not be the same as 1 (oid=N).' do
      @tc.refute_same 1, 1
    end
  end

  def test_skip
    @assertion_count = 0

    util_assert_triggered "haha!", MiniTest::Skip do
      @tc.skip "haha!"
    end
  end

  def util_assert_triggered expected, klass = MiniTest::Assertion
    e = assert_raises(klass) do
      yield
    end

    msg = e.message.sub(/(---Backtrace---).*/m, '\1')
    msg.gsub!(/\(oid=[-0-9]+\)/, '(oid=N)')
    msg.gsub!(/(Run options:).+/, '\1')

    assert_equal expected, msg
  end

  if ENV['DEPRECATED'] then
    require 'test/unit/assertions'
    def test_assert_nothing_raised
      @tc.assert_nothing_raised do
        # do nothing
      end
    end

    def test_assert_nothing_raised_triggered
      expected = 'Exception raised:
Class: <RuntimeError>
Message: <"oops!">
---Backtrace---'

      util_assert_triggered expected do
        @tc.assert_nothing_raised do
          raise "oops!"
        end
      end
    end
  end
end
