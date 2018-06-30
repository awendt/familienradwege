build: dist dist/traberweg.xml all.xml

dist:
	mkdir dist

dist/traberweg.xml: berlin/traberweg.osm
	curl --data @berlin/traberweg.osm http://overpass-api.de/api/interpreter > dist/traberweg.xml

osmconvert: osmconvert.c
	cc osmconvert.c -lz -o osmconvert

osmconvert.c:
	wget http://m.m.i24.cc/osmconvert.c

all.xml: osmconvert dist/traberweg.xml
	./osmconvert dist/*.xml -o=all.xml
