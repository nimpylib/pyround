# Package

version       = "0.1.0"
author        = "litlighilit"
description   = "round function like Python's (with 2nd arg and round-to-even)"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim > 2.0.8"

var pylibPre = "https://github.com/nimpylib"
let envVal = getEnv("NIMPYLIB_PKGS_BARE_PREFIX")
if envVal != "": pylibPre = ""
#if pylibPre == Def: pylibPre = ""
elif pylibPre[^1] != '/':
  pylibPre.add '/'
template pylib(x, ver) =
  requires if pylibPre == "": x & ver
           else: pylibPre & x

pylib "pysimperr", " ^= 0.1.0"
pylib "dtoa_c", " ^= 0.1.0"
pylib "autoconf_sugars", " ^= 0.1.0"
pylib "errno", " ^= 0.1.0"
pylib "pymath", " ^= 0.1.0"
# only isX.isfinite needed



