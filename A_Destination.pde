// these are all of the points from google in a long list
// I select out the year

class Destination {

  long timestamp, accuracy;
  float lon, lat;
  float x, y;

  Destination(long ts, long lon, long lat, long accuracy) {
    timestamp = ts;
    this.lon = lon / 10000000.0;
    this.lat = lat/10000000.0; 
    this.accuracy = accuracy;
    setLoc();
  }

  void setLoc() {
    Location l = new Location(lat, lon);
    ScreenPosition loc = map.getScreenPosition(l);
    x = loc.x;
    y = loc.y;

  }
  
  boolean include() {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  JSONObject  getJSON() {
    JSONObject json;

    json = new JSONObject();

    json.setFloat("x", x);
    json.setFloat("y", y);

    return json;
  }
}
