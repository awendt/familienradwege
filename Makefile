QUERIES=$(addprefix dist/,$(shell ls -1 berlin))
XMLS=$(QUERIES:.txt=.osm)

build: dist $(XMLS) website/all.json

install: node_modules tools/osmconvert

node_modules:
	npm install osmtogeojson parcel-bundler

dist:
	mkdir dist

dist/%.osm: berlin/%.txt
	curl --data @$< http://overpass-api.de/api/interpreter > $@

tools/osmconvert:
	$(MAKE) -C tools

all.osm: tools/osmconvert $(XMLS)
	tools/osmconvert $(XMLS) -o=all.osm

website/all.json: all.osm
	npx osmtogeojson all.osm > website/all.json
