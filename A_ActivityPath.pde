import java.util.Iterator;

void binPaths() {
  // get rid of empty
  println("BIN0", paths.size());
  for (Iterator<ActivityPath> iterator = paths.iterator(); iterator.hasNext(); ) {
    ActivityPath p = iterator.next();
    if (p.points.size() < 1) {
      iterator.remove();
    }
  }
  println("BIN1", paths.size());

  //int[][] binned = new int[tribin.r][tribin.c];
  //ArrayList<ActivityPath> binnedPaths = new ArrayList<ActivityPath>();
  //for (int r = 0; r < binned.length; r++) {
  //  for (int c = 0; c < binned[0].length; c++) {
  //    binned[r][c] = 0;
  //  }
  //}
  

  int j = 0;
  while (j < paths.size()-1) {
    ActivityPath path0 = paths.get(j);
    int i = j+1;
    while (i < paths.size()) {
     if (path0.checkDupe(paths.get(i))) {
        path0.addDupe(paths.get(i));
        paths.remove(i);
      } else {
        i++;
      }
    }
    j++;
  }
  
  println("BIN2", paths.size());


  
}

void savePathsJSON() {
  Collections.sort(paths);
  println(paths);

  JSONObject pathjson = new JSONObject();
  JSONArray patharr = new JSONArray();
  for (int i = 0; i < paths.size(); i++) {
    JSONObject obj = new JSONObject();
    obj.setFloat("lat0", paths.get(i).lat0);
    obj.setFloat("lon0", paths.get(i).lon0);
    obj.setFloat("lat1", paths.get(i).lat1);
    obj.setFloat("lon1", paths.get(i).lon1);
    obj.setInt("dupes", paths.get(i).dupes.size());
    patharr.setJSONObject(i, obj);
  }
  pathjson.setJSONArray("paths", patharr);
  saveJSONObject(pathjson, "data/output/paths.json");
}

class Act {
  String type;
  long ts;
  Act(String type, long ts) {
    this.type = type;
    this.ts = ts;
  }
}

class ActivityPath implements Comparable<ActivityPath> {

  ArrayList<Destination> connections;
  long startTs, endTs;
  float duration, distance;
  String activity;
  color col;
  int rStart, cStart, rEnd, cEnd;
  ArrayList<Act>dupes;
  ArrayList<PVector>points;

  float lat0, lon0, lat1, lon1;

  ActivityPath(long[][] coords, long ts, long endts, float distance, String activity) {
    setLoc(coords);
    setStartEnd();
    dupes = new ArrayList<Act>();
    this.startTs = ts;
    this.endTs = endts;
    this.duration = endts - ts;
    this.distance = distance;
    this.activity = activity;
    col = color(random(255), random(255), random(255));
  }

  @Override
    public int compareTo(ActivityPath o) {
    Integer f1 = dupes.size();
    Integer f2 = o.dupes.size();
    return f2.compareTo(f1);
  }

  @Override
    public String toString() {
    return dupes.size()+"";
  }
  
  boolean checkDupe(ActivityPath p0) {
    boolean a = (rStart == p0.rStart && cStart == p0.cStart && rEnd == p0.rEnd && cEnd == p0.cEnd);
    return a;
  }

  void display() {
    strokeWeight(2);
    if (activity.equals("CYCLING")) stroke(color(greenColor, 100));
    else if (activity.equals("WALKING")) stroke(color(redColor, 100));
    else stroke(color(yellowColor, 100));


    //for (int i = 0; i < points.size()-1; i++) {
    //  PVector p0 = points.get(i);
    //  PVector p1 = points.get(i+1);
    //  line(p0.x, p0.y, p1.x, p1.y);
    //}

    //float v = dupes.size();
    //if (v == 0) stroke( redColor);
    //else if (v == 1) stroke( yellowColor);
    //else if (v == 2) stroke( blueColor);
    //else stroke( greenColor);
    if (points.size() > 0) {
      int spaceZ = 0;
      PVector start = points.get(0);
      start.z =  tribin.elevations[rStart][cStart] + spaceZ;

      PVector end = points.get(points.size()-1);
      end.z =  tribin.elevations[rEnd][cEnd] + spaceZ;
      float d = dist(start.x, start.y, end.x, end.y);

      //float thick = map(d, 30, 200, .5, 3);
      float thick = map(dupes.size(), 0, 2.5, .5, 10);
      thick = constrain(thick, .5, 10);
      strokeWeight(thick);
      line(start.x, start.y, start.z, end.x, end.y, end.z);

      //PVector previous = new PVector(start.x, start.y);
      //int spacing = 10;
      //float d = dist(start.x, start.y, end.x, end.y);
      //for (int i = spacing; i < d; i += spacing) {
      //  PVector p = start.lerp(end, map(i, 0, d, 0, 1));
      //  rc = tribin.pixToBins(int(p.x), int(p.y));
      //  float z = tribin.elevations[rc[0]][rc[1]] + spaceZ;
      //  p.z = z;
      //  line(previous.x, previous.y, previous.z, p.x, p.y, p.z);
      //  previous = p;
      //}
      //line(previous.x, previous.y, previous.z, end.x, end.y, end.z);
    }
  }

  void displayConnections() {
    for (int i = 0; i < connections.size()-1; i++) {
      stroke(col);
      line(connections.get(i).x, connections.get(i).y, connections.get(i+1).x, connections.get(i+1).x);
      ellipse(connections.get(i).x, connections.get(i).y, 10, 10);
    }
  }

  void connectToPoints() {
    connections = new ArrayList<Destination>();
    for (int i = 0; i < destinations.size(); i++) {
      if (destinations.get(i).timestamp >= startTs && destinations.get(i).timestamp <= endTs) {
        connections.add(destinations.get(i));
      }
    }
  }


  void addDupe(ActivityPath a) {
    dupes.add(new Act(a.activity, a.startTs));
  }

  void displayCircle() {
    strokeWeight(2);
    if (activity.equals("CYCLING")) stroke(0, 255, 255);
    else if (activity.equals("WALKING")) stroke(0, 255, 0);
    else stroke(255, 0, 0, 80);

    fill(col);
    // points.size()-1
    //for (int i = 0; i < points.size()-1; i++) {
    //  PVector p0 = points.get(i);
    //  PVector p1 = points.get(i+1);
    //  line(p0.x, p0.y, p1.x, p1.y);
    //}
    //for (int i = 0; i < points.size(); i++) {
    //  PVector p0 = points.get(i);
    //  ellipse(p0.x, p0.y, 10, 10);
    //}

    if (points.size() > 1) {
      PVector start = points.get(0);
      PVector end = points.get(points.size()-1);
      noFill();
      stroke(col);
      pushMatrix();
      float d = dist(end.x, end.y, start.x, start.y);
      float dx = end.x-start.x;
      float dy = end.y-start.y;
      float ang = atan2(dy, dx);
      //translate(dx/2, dy/2);
      translate((start.x+end.x)/2, (start.y+end.y)/2);
      rotateY(PI/2);
      rotateX(ang);
      ellipse(0, 0, d, d);
      popMatrix();
    }
  }

  void setStartEnd() {
    if (points.size() > 1) {
      PVector start = points.get(0);
      int [] rc = tribin.pixToBins(int(start.x), int(start.y));
      rStart = rc[0];
      cStart = rc[1];

      PVector end = points.get(points.size()-1);
      rc = tribin.pixToBins(int(end.x), int(end.y));
      rEnd = rc[0];
      cEnd = rc[1];
    }
  }

  //void setLoc(long[][] coords) {
  //  points = new ArrayList<PVector>();
  //  float lat0 = coords[0][0]/ 10000000.0;
  //  float lon0 = coords[0][1]/ 10000000.0;
  //  float lat1 = coords[1][0]/ 10000000.0;
  //  float lon1 = coords[1][1]/ 10000000.0;

  //  Location l0 = new Location(lat0, lon0);
  //  ScreenPosition loc0 = map.getScreenPosition(l0);

  //  Location l1 = new Location(lat1, lon1);
  //  ScreenPosition loc1 = map.getScreenPosition(l1);

  //  if (withinScreen(loc0) && withinScreen(loc1)) {
  //    points.add(new PVector(loc0.x, loc0.y));
  //    points.add(new PVector(loc1.x, loc1.y));
  //  }
  //}

  void setLoc(long[][] coords) {
    points = new ArrayList<PVector>();
    for (long[] coord : coords) {

      float lat = coord[0]/ 10000000.0;
      float lon = coord[1]/ 10000000.0;
      Location l = new Location(lat, lon);
      ScreenPosition loc = map.getScreenPosition(l);

      if (withinScreen(loc)) points.add(new PVector(constrain(loc.x, 0, width), constrain(loc.y, 0, height)));
      else {
        if (points.size() < 2) {
          points = new ArrayList<PVector>();
        }
      }
    }
    lat0 = coords[0][0]/ 10000000.0;
    lon0 = coords[0][1]/ 10000000.0;
    lat1 = coords[1][0]/ 10000000.0;
    lon1 = coords[1][1]/ 10000000.0;
  }

  boolean withinScreen(PVector p) {
    return (p.x >= 0 && p.y >= 0 && p.x < width && p.y < height);
  }
}
