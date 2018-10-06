#!/usr/bin/env node

var osmium = require('osmium'),
    haversine = require('haversine'),
    builder = require('xmlbuilder');

if (process.argv.length != 4) {
    console.log("Usage: " + process.argv[0] + ' ' + process.argv[1] + " OSMFILE MINLENGTH");
    process.exit(1);
}

var input_filename = process.argv[2];
var minlength = process.argv[3];

// =====================================

var handler = new osmium.Handler();

var xml = builder.create('osmChange');
var deletes = [];

handler.on('way', function(way) {
  node_coordinates = way.node_coordinates().slice();

  distance = 0;
  while( (start = node_coordinates.shift()) !== undefined && (end = node_coordinates[0]) !== undefined ) {
    distance += haversine(start, end, {unit: 'meter', format: '{lon,lat}'});
  }

  if (distance < minlength) {
    deletes.push({way: {'@id': way.id}})
  }
});

var file = new osmium.File(input_filename, 'osm');
var reader = new osmium.Reader(file);

var location_handler = new osmium.LocationHandler();

osmium.apply(reader, location_handler, handler);
xml.end({ pretty: true});

var xml = builder.create({
  osmChange: {
    delete: deletes
  }
}, { encoding: 'utf-8' })
console.log(xml.end({ pretty: true }));
