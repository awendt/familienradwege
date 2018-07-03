var mymap = L.map('mapid').setView([52.480, 13.454], 13);

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

var oReq = new XMLHttpRequest();
oReq.addEventListener("load", renderGeoJSON);
oReq.open("GET", "/all.json");
oReq.send();
