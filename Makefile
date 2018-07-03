QUERIES=$(addprefix dist/,$(shell ls -1 berlin))
XMLS=$(QUERIES:.osm=.xml)

build: dist $(XMLS) website/all.json

install: node_modules osmconvert.c

node_modules:
	npm install osmtogeojson parcel-bundler

dist:
	mkdir dist

dist/%.xml: berlin/%.osm
	curl --data @$< http://overpass-api.de/api/interpreter > $@

osmconvert: osmconvert.c
	cc osmconvert.c -lz -o osmconvert

osmconvert.c:
	wget http://m.m.i24.cc/osmconvert.c

all.osm: osmconvert $(XMLS)
	./osmconvert dist/*.xml -o=all.osm

website/all.json: all.osm
	npx osmtogeojson all.osm > website/all.json
