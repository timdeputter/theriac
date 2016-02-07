Theriac [![Build Status](https://travis-ci.org/timdeputter/theriac.svg?branch=master)](https://travis-ci.org/timdeputter/theriac) [![Hex.pm package version](https://img.shields.io/hexpm/v/theriac.svg?style=flat)](https://hex.pm/packages/theriac) [![Coverage Status](https://coveralls.io/repos/timdeputter/theriac/badge.svg?branch=master)](https://coveralls.io/r/timdeputter/theriac?branch=master) [![License](http://img.shields.io/hexpm/l/theriac.svg?style=flat)](https://github.com/timdeputter/theriac/blob/master/LICENSE.md)
==========


Implementation of Transducers in elixir. This was a fun way to learn more about the functional side of elixir, and I also thought having transducers in elixir could be useful.
But after I realized that transducers and streams are the same (some minor differences in implementation).
Transducers are more push oriented and streams are pull, but if you have a receiving function as source,
streams can be push based too.

So, long story short, if you need something like transducers in elixir, use streams.


## License

Check [LICENSE](LICENSE) file for more information.
