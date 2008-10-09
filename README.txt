= minitest_tu_shim

* http://rubyforge.org/projects/bfts

== DESCRIPTION:

minitest_te_shim bridges the gap between the small and fast minitest
and ruby's huge and slow test/unit.

== FEATURES/PROBLEMS:

* Fully test/unit compatible assertions.
* Allows test/unit to be required, firing up an autorunner.
* Incompatible at the runner level. Does not replicate test/unit's internals.

== HOW TO USE:

+ sudo gem install minitest_tu_shim
+ sudo use_minitest yes
+ there is no step 3.

== REQUIREMENTS:

+ minitest
+ Ruby 1.8, maybe even 1.6 or lower. No magic is involved.

== INSTALL:

+ sudo gem install minitest_tu_shim

== LICENSE:

(The MIT License)

Copyright (c) Ryan Davis, Seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
