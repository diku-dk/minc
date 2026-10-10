(* The signature of smlfut-generated modules that minc can handle.

We do not actually usef all of the functionality described herein. *)

signature FUTHARK_MONO_ARRAY =
sig
  type array
  type ctx
  type shape
  type index
  type raw
  structure Array: MONO_ARRAY
  structure Slice: MONO_ARRAY_SLICE
  val new: ctx -> Slice.slice -> shape -> array
  val free: array -> unit
  val shape: array -> shape
  val index: array -> index -> Array.elem
  val values: array -> Array.array
  val values_into: array -> Slice.slice -> unit
  val new_raw: ctx -> raw -> shape -> array
  val values_raw: array -> raw
end

signature FUTHARK_OPAQUE =
sig
  type t
  type ctx
  val free: t -> unit
  val store: t -> Word8Array.array
  val restore: ctx -> Word8ArraySlice.slice -> t
end

signature MONOID =
sig
  type ctx

  exception Error of string
  exception Free

  type cfg =
    { logging: bool
    , debugging: bool
    , profiling: bool
    , cache: string option
    , tuning: (string * int) list
    }

  structure Config:
  sig
    val default: cfg
    val logging: bool -> cfg -> cfg
    val debugging: bool -> cfg -> cfg
    val profiling: bool -> cfg -> cfg
    val cache: string option -> cfg -> cfg
    val tuning: (string * int) list -> cfg -> cfg
  end

  structure Context:
  sig
    val new: cfg -> ctx
    val free: ctx -> unit
    val sync: ctx -> unit
    val report: ctx -> string
    val pauseProfiling: ctx -> unit
    val unpauseProfiling: ctx -> unit
    val clearCaches: ctx -> unit
  end

  (* []u8 *)
  structure Word8Array1: FUTHARK_MONO_ARRAY
                         where type ctx = ctx
                         and type shape = int
                         and type index = int
                         and type Array.array = Word8Array.array
                         and type Array.elem = Word8Array.elem
                         and type Slice.slice = Word8ArraySlice.slice
                         and type Slice.elem = Word8ArraySlice.elem
                         and type raw = foreignptr

  structure Opaque:
  sig
    (* m *)
    structure m: FUTHARK_OPAQUE where type ctx = ctx
  end

  structure Entry:
  sig
    val comb: ctx -> Opaque.m.t * Opaque.m.t -> Opaque.m.t
    val obs: ctx -> Opaque.m.t -> Word8Array1.array
    val red: ctx -> Word8Array1.array -> Opaque.m.t
  end
end
