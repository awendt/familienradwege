function load_json(file, cb) {
  var oReq = new XMLHttpRequest();
  oReq.addEventListener("load", cb);
  oReq.open("GET", "/"+ file +".json");
  oReq.send();
}

export { load_json };
