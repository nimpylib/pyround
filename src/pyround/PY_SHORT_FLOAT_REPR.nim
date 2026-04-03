
import pkg/dtoa_c
import pkg/errno/[errnoUtils, errnoConsts]
import ./err

proc PyOS_snprintf(str: cstring, size: csize_t|int): cint{.discardable, importc: "snprintf", header: "<stdio.h>", cdecl, varargs.}
# Include/internal/pycore_pymath.h

proc round*(dd: float, ndigits: int): float =
  ##[ version of double_round that uses the correctly-rounded string<->double
    conversions from Python/dtoa.c ]##
  const MyBufLen = 100
  var
    mybuflen = MyBufLen
    buf, buf_end: cstring
    shortbuf: array[MyBufLen, cchar]
    mybuf: cstring = cast[cstring](addr shortbuf[0])
    decpt: c_int
    sign: bool

  # round to a decimal string

  buf = dtoa(dd.cdouble, DTOA_DECIMAL, ndigits.cint, decpt, sign, buf_end)
  defer: freedtoa buf

  template chkNoMem(p: ptr|cstring) =
    if p.isNil:
      raise newException(OutOfMemDefect, "")
  buf.chkNoMem

  #[Get new buffer if shortbuf is too small.  Space needed <= buf_end -
    buf + 8: (1 extra for '0', 1 for sign, 5 for exp, 1 for '\0').]#
  let buflen = cast[int](buf_end) - cast[int](buf)

  assert buf_end.isNil.not
  assert buflen >= 0
  if buflen  + 8 > mybuflen:
    mybuflen = buflen + 8
    mybuf = cast[cstring](alloc mybuflen)
    mybuf.chkNoMem

  # copy buf to mybuf, adding exponent, sign and leading 0
  PyOS_snprintf(mybuf, mybuflen, "%s0%se%d",
                (if sign: cstring"-" else: cstring""),
                buf, decpt - buflen.cint)

  # and convert the resulting string back to a double
  prepareRWErrno
  setErrno0

  result = strtod(mybuf)


  if isErr(ERANGE) and abs(result) >= 1:
    raise newException(err.OverflowError, "rounded value too large to represent")

  # done computin value
  if cast[ptr cchar](mybuf) != shortbuf[0].addr:
    dealloc mybuf

