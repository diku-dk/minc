# minc - monoids, incrementally

Minc is a small program that provides orchestration of monoidal computation
expressed in [Futhark](https://futhark-lang.org). The purpose of Minc is to pass
file contents to monoidal reduction, store the monoid value in a file, combine
such partial results, and finally to print a human-readable representation of
the result. The idea is to demonstrate how monoids allow for clean and very
flexible incremental and distributed computing.

Minc itself is written in Standard ML, and uses
[`smlfut`](https://github.com/diku-dk/smlfut) to interact with the monoidal
Futhark code.

Changing which monoid is being used requires you to modify the file
[futhark/monoid.fut](futhark/monoid.fut) and recompile Minc. For writing fancy
monoids, see the [monoidal library](https://github.com/diku-dk/monoidal).

## Usage

First compile Minc with `make`, which requires MLKit, Futhark, and `smlfut` to
be available. Then the following invocations are possible:

### Reduction

```
$ ./minc red infile resfile
```

Reduce the contents of `infile` (viewed as a byte sequence), and store the
result in `resfile`.

### Observation

```
$ ./minc obs resfile
```

Print a human-readable representation of `resfile`, which must have been
produced by `minc`.

### Combination

```
$ ./minc resfile_a resfile_b resfile_c
```

Read the two files `resfile_a` and `resfile_b`, which must have been produced by
`minc`, combine their partial results, and write the it to `resfile_c`.

## Example

Split `example.txt` arbitrarily and produce partial results:

```
$ ./minc red <(head -c -10 example.txt) a.res
$ ./minc red <(tail -c 10 example.txt) b.res
```

Combine the partial results:

```
$ ./minc op a.res b.res c.res
```

Observe the result:

```
$ ./minc obs c.res
35.066
```
