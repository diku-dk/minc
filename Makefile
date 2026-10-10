FUTHARK_BACKEND=c

minc: minc.mlb minc.sml futhark/libmonoid.a
	mlkit -o minc -libdirs futhark/ -libs m,c,dl,monoid -no_gc minc.mlb

futhark/monoid.smlfut.c: futhark/monoid.fut
	futhark $(FUTHARK_BACKEND) --library futhark/monoid.fut
	smlfut --target=mlkit futhark/monoid.json -o futhark

futhark/libmonoid.a: futhark/monoid.smlfut.c
	cc -c -O futhark/monoid.c -o futhark/monoid.o
	cc -c -O -Wall -Wextra futhark/monoid.smlfut.c -o futhark/monoid.smlfut.o
	ar r futhark/libmonoid.a futhark/monoid.o futhark/monoid.smlfut.o
