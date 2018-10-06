install: osmconvert osmfilter

osmconvert: osmconvert.c
	cc osmconvert.c -lz -o osmconvert

osmconvert.c:
	wget http://m.m.i24.cc/osmconvert.c

osmfilter: osmfilter.c
	cc -x c osmfilter.c -O3 -o osmfilter

osmfilter.c:
	wget http://m.m.i24.cc/osmfilter.c
