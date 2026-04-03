
import std/unittest

import pyround
test "round":
  check round(1.23) == 1.0
  check round(1.234, 2) == 1.23

