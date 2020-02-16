.PHONY: clean install

install: osmconvert osmfilter

clean:
	git clean -f -X

osmconvert: integrity osmconvert.c
	cc osmconvert.c -lz -o osmconvert

osmconvert.c:
	wget --quiet http://m.m.i24.cc/osmconvert.c

osmfilter: integrity osmfilter.c
	cc -x c osmfilter.c -O3 -o osmfilter

osmfilter.c:
	wget --quiet http://m.m.i24.cc/osmfilter.c

integrity: checksumfile osmfilter.c osmconvert.c
	shasum -c checksumfile
	touch integrity
