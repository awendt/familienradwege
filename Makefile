ROAD_QUERIES=$(addprefix dist/roads/,$(shell ls -1 berlin/roads))
ROAD_XMLS=$(ROAD_QUERIES:.txt=.osm)

MANUAL_QUERIES=$(addprefix dist/manual/,$(shell ls -1 berlin/manual))
MANUAL_XMLS=$(MANUAL_QUERIES:.txt=.osm)

build: dist $(ROAD_XMLS) $(MANUAL_XMLS) website/roads.json website/manual.json

install: node_modules tools/osmconvert

node_modules:
	npm install osmtogeojson parcel-bundler

dist:
	mkdir -p dist/roads
	mkdir -p dist/manual

dist/roads/%.osm: berlin/roads/%.txt
	curl --data @$< http://overpass-api.de/api/interpreter > $@

dist/manual/%.osm: berlin/manual/%.txt
	curl --data @$< http://overpass-api.de/api/interpreter > $@

tools/osmconvert:
	$(MAKE) -C tools

roads.osm: tools/osmconvert $(ROAD_XMLS)
	tools/osmconvert $(ROAD_XMLS) -o=roads.osm

manual.osm: tools/osmconvert $(MANUAL_XMLS)
	tools/osmconvert $(MANUAL_XMLS) -o=manual.osm

website/roads.json: roads.osm
	npx osmtogeojson roads.osm > website/roads.json

website/manual.json: manual.osm
	npx osmtogeojson manual.osm > website/manual.json
