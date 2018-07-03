QUERIES=$(addprefix dist/,$(shell ls -1 berlin))
XMLS=$(QUERIES:.txt=.osm)

build: dist $(XMLS) website/all.json

install: node_modules osmconvert.c

node_modules:
	npm install osmtogeojson parcel-bundler

dist:
	mkdir dist

dist/%.osm: berlin/%.txt
	curl --data @$< http://overpass-api.de/api/interpreter > $@

osmconvert: osmconvert.c
	cc osmconvert.c -lz -o osmconvert

osmconvert.c:
	wget http://m.m.i24.cc/osmconvert.c

all.osm: osmconvert $(XMLS)
	./osmconvert dist/*.osm -o=all.osm

website/all.json: all.osm
	npx osmtogeojson all.osm > website/all.json
