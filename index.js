import { translate_keys } from './i18n';
import { map, layers } from './map';
import { load_json } from './data';

// Mapbox looks beautiful but requires an API token
// see https://wiki.openstreetmap.org/wiki/Tiles
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
  maxZoom: 18
}).addTo(map);

Object.keys(layers).forEach(function(key) {
  const layer = layers[key];
  layer.addTo(map);

  load_json(key, function() {
    const geojsonFeature = JSON.parse(this.responseText);
    layer.addData(geojsonFeature);
  });
});

L.control.layers({}, translate_keys(layers)).addTo(map);
