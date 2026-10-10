-- Do not modify the module type, but feel free to modify the implementation.
-- The example here is taken from the monoidal library, and processes strings
-- composed of comma-separated numbers grouped by bars, and computes the maximum
-- of the average of the groups.
module monoid
  : {
      -- The monoidal result type.
      type t

      -- Inject a single byte into the monoid.
      val gen : u8 -> t

      -- Monoidal operator.
      val op : t -> t -> t

      -- Neutral element for 'op'.
      val ne : t

      -- Produce externally readable representation of the monoidal value. The
      -- u8 array will be interpreted as a string.
      val obs : t -> ?[k].[k]u8
    } = {
  -- Modify only the contents of this module, not anything outside of it.

  import "lib/github.com/diku-dk/monoidal/monoidal"

  module avg (X: numeric) : monoid with i = X.t with o = X.t = {
    open monoidal.dup {type i = X.t} (monoidal.prod (monoidal.sum X) (monoidal.count {type i = X.t}))

    type o = X.t

    def obs =
      \(t: t) : o ->
        let (s, c) = obs t
        in if c == 0 then X.i64 0 else s X./ (X.i64 c)
  }

  module groups = monoidal.chunk (monoidal.max f64) (monoidal.optone f64) {
    def del_ign (c: u8) : bool = c == '|'
  }

  module items = monoidal.chunk (avg f64) groups {
    def del_ign (c: u8) : bool = c == ','
  }

  module M = monoidal.chunk (monoidal.float f64) items {
    def del_ign (_: u8) : bool = false
  }

  module T = monoidal.with_gen M {
    type i = u8

    def gen (c: i) : M.i =
      if ('0' <= c && c <= '9') || c == '.' || c == '-' then #E c else #Del c
  }

  -- Print decimal representation with a and b digits before and
  -- after the decimal point.
  def ftoa (a: i64) (b: i64) (x: f64) : [a + 1 + b]u8 =
    tabulate (a + 1 + b) \i ->
      if i < a
      then u8.i64 ((i64.f64 x / 10 ** (a - i - 1) % 10) + '0')
      else if i == a
      then '.'
      else u8.i64 (i64.f64 (x * (10 ** f64.i64 (i - a))) % 10 + '0')

  type t = T.t
  def gen = T.gen
  def op = T.op
  def ne = T.ne

  def obs x =
    let x' = (T.obs x)
    in ftoa (i64.f64 (f64.ceil (f64.log10 x'))) 3 x'
}

-- Do not modify anything below this line.

type m = monoid.t
entry obs : m -> []u8 = monoid.obs
entry comb : m -> m -> m = monoid.op
entry red [n] : [n]u8 -> m = map monoid.gen >-> reduce comb monoid.ne
