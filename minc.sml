val arrayToString = Byte.bytesToString o Word8Array.vector

fun arraySliceFromFile fname =
  let
    val s = BinIO.inputAll (BinIO.openIn fname)
    val n = Word8Vector.length s
  in
    Word8ArraySlice.full (Word8Array.tabulate (n, fn i =>
      Word8Vector.sub (s, i)))
  end

functor MkMinc(M: MONOID) =
struct

  fun restoreMonoid ctx fname =
    M.Opaque.m.restore ctx (arraySliceFromFile fname)

  fun storeMonoid ctx fname x =
    BinIO.output (BinIO.openOut fname, (Word8Array.vector (M.Opaque.m.store x)))

  fun run () =
    (case CommandLine.arguments () of
       ["red", inname, outname] =>
         let
           val ctx = M.Context.new M.Config.default
           val s = arraySliceFromFile inname
           val s' = M.Word8Array1.new ctx s (Word8ArraySlice.length s)
           val x = M.Entry.red ctx s'
           val () = storeMonoid ctx outname x
         in
           M.Opaque.m.free x;
           M.Word8Array1.free s';
           M.Context.free ctx
         end
     | ["obs", fname] =>
         let
           val ctx = M.Context.new M.Config.default
           val x = restoreMonoid ctx fname
           val y = M.Entry.obs ctx x
           val y' = M.Word8Array1.values y
           val () = print (arrayToString y' ^ "\n")
         in
           M.Opaque.m.free x;
           M.Word8Array1.free y;
           M.Context.free ctx
         end
     | ["op", fname_x, fname_y, outname] =>
         let
           val ctx = M.Context.new M.Config.default
           val x = restoreMonoid ctx fname_x
           val y = restoreMonoid ctx fname_y
           val z = M.Entry.comb ctx (x, y)
           val () = storeMonoid ctx outname z
         in
           M.Opaque.m.free x;
           M.Opaque.m.free y;
           M.Opaque.m.free z;
           M.Context.free ctx
         end
     | _ => (print "Invalid usage\n"; OS.Process.exit OS.Process.failure))
    handle M.Error s => (print s; OS.Process.exit OS.Process.failure)
end

structure Minc = MkMinc(monoid)

val () = Minc.run ()
