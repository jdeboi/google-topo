class PlaceVisit extends Destination {
  
  String name, address;
  float duration;
  String placeID;
  
  // my map; markers bigger based on location
  // question as to what role google plaed in this topography
  
  PlaceVisit(long ts, long endts, long lon, long lat, long accuracy, String name, String address, String placeID) {
    super(ts, lon, lat, accuracy);
    this.name = name;
    this.address = address;
    this.placeID = placeID;
    
    long dt = endts - ts;
    duration = dt/1000.0;
    
    setLoc();
  }
  
  
  void display() {
    fill(255);
    text(name, x, y);
  }

  
  
}
