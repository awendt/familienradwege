build: dist dist/traberweg.xml all.json

install: node_modules osmconvert.c

node_modules:
	npm install osmtogeojson

dist:
	mkdir dist

dist/traberweg.xml: berlin/traberweg.osm
	curl --data @berlin/traberweg.osm http://overpass-api.de/api/interpreter > dist/traberweg.xml

osmconvert: osmconvert.c
	cc osmconvert.c -lz -o osmconvert

osmconvert.c:
	wget http://m.m.i24.cc/osmconvert.c

all.osm: osmconvert dist/traberweg.xml
	./osmconvert dist/*.xml -o=all.osm

all.json: all.osm
	npx osmtogeojson all.osm > all.json
