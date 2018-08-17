import { translate_keys } from './i18n';

var mymap = L.map('mapid').setView([52.480, 13.454], 12);

// Mapbox looks beautiful but requires an API token
// see https://wiki.openstreetmap.org/wiki/Tiles
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
  maxZoom: 18
}).addTo(mymap);

function renderGeoJSON() {
  geojsonFeature = JSON.parse(this.responseText);
  L.geoJSON(geojsonFeature, {
    pointToLayer: function() {}
  }).addTo(mymap);
}

var addDataFor = function(layer) {
  return function renderGeoJSON() {
    const geojsonFeature = JSON.parse(this.responseText);
    layer.addData(geojsonFeature);
  }
};

var geojson_options = {
  pointToLayer: function() {}
};

var layers = {
  roads: new L.geoJSON(undefined, geojson_options),
  manual: new L.geoJSON(undefined, geojson_options)
};

Object.keys(layers).forEach(function(key) {
  const layer = layers[key];
  layer.addTo(mymap);

  var oReq = new XMLHttpRequest();
  oReq.addEventListener("load", addDataFor(layer));
  oReq.open("GET", "/"+ key +".json");
  oReq.send();
});

L.control.layers({}, translate_keys(layers)).addTo(mymap);
