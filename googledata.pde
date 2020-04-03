import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.mapdisplay.MapDisplayFactory;
UnfoldingMap map;

import peasy.PeasyCam;
PeasyCam cam;
float rot = 0;

import blobDetection.*;

import java.util.Date;

final int AGGREGATE_YEAR = 0;
final int AGGREGATE_MONTH = 1;
final int AGGREGATE_DAY = 2;
final int AGGREGATE_ALL = 3;

int AGGREGATE_MODE = 3;

int year = 2019;
int startDay = 1;
int startMonth = 1;

//HexBin hexbin;
TriBin tribin;
float binSize = 4;
ArrayList<Destination> destinations;
ArrayList<Destination> places;
ArrayList<ActivityPath> paths;
ArrayList<ActivityStop>activityStops;

PVector ave;

PImage tex; //marker;
PShape marker;

float rotateX = 0.9f;
float rotateZ = (float) 0;
float rotateVelocityZ = 0.003f;

boolean DRAWING_CONTOURS = false;
Terrain water;


public void settings() {
  size(1000, 1000, P3D);
  pixelDensity(2);
}

void setup() {
  cam = new PeasyCam(this, 400);
  cam.setSuppressRollRotationMode();

  rectMode(CENTER);

  initColors();

  tribin = new TriBin(binSize);
  initMap();
  initTerrain();
  water = new Terrain (20);
  initContours();

  initPaths();
  binPaths();
  savePathsJSON();

  tex = loadImage("google.jpg");
  marker = loadShape("marker.svg");
}

void draw() {
  lights();


  background(0);

  // drawmap
  translate(-map.getWidth() / 2, -map.getHeight() / 2);
  pushMatrix();
  translate(0, 0, 1.5);
  //map.draw();
  image(tex, 0, 0);
  popMatrix();


  //tribin.displayPlaceBins();
  displayPaths();

  //drawElevations(this.g, tribin.elevations, binSize);
  //displayMarkers();

  //displayContours();
  //water.display(10*sin(millis()/4000.0));

  displayHUD();
}

void keyPressed() {
  if (key == 's') {
    saveFrame();
    exit();
  } 

  if (AGGREGATE_MODE !=AGGREGATE_ALL) {
    if (keyCode==RIGHT) {
      year++;
      if (year > 2020) year = 2017;
      initTerrain();
    } else if (keyCode == LEFT) {
      year--;
      if (year < 2017) year = 2020;
      initTerrain();
    }
  }
  if (key == 'r') {
    record = true;
  }

  //if (key == 'p') {
  //  riverPoints.add(new RiverPoint(mouseX, mouseY));
  //}
}

void initTerrain() {

  initDestinations();
  initPlaces();


  editDestinations();
  editPlaces();

  tribin.resetBins();
  binDestinations();
  binPlaces();


  setTerrain(tribin.elevations);
  tribin.setStats();

  saveJSON();

  setPopularPlaces();
}

void initMap() {
  // init map
  float homeLat = 29.9307079;
  float homeLon = -90.105797;
  map = new UnfoldingMap(this, new Microsoft.AerialProvider());
  map.zoomAndPanTo(13, new Location(homeLat+.03, homeLon+.02));
  //MapUtils.createDefaultEventDispatcher(this, map);
}

void initDestinations() {
  destinations = new ArrayList<Destination>();
  switch(AGGREGATE_MODE) {
  case AGGREGATE_YEAR:
    initDestinations(true, false, false);
    break;
  case  AGGREGATE_MONTH:
    initDestinations(true, true, false);
    break;
  case AGGREGATE_DAY:
    initDestinations(true, true, true);
    break;
  default:
    initDestinations(false, false, false);
    break;
  }
}

// if byYear = true and byMonth = false, gets all of year
// if byMonth = true, gets by year and by month
// otherwise, gets all
void initDestinations(boolean byYear, boolean byMonth, boolean byDay) {
  JSONObject history = loadJSONObject("originals/Location History.json");
  JSONArray locations = history.getJSONArray("locations");
  for (int i = 0; i < locations.size(); i++) {
    JSONObject obj = locations.getJSONObject(i);
    long  timestampMs = obj.getLong("timestampMs");
    long lat =  obj.getLong("latitudeE7");
    long lon =  obj.getLong("longitudeE7");
    long acc =  obj.getLong("accuracy");
    Date d = new Date(timestampMs);
    if (byDay) {
      if (d.getYear()+1900 == year && d.getDate() == startDay && d.getMonth()+1 == startMonth) {
        destinations.add(new Destination(timestampMs, lon, lat, acc));
      }
    } else if (byMonth) {
      if (d.getYear()+1900 == year && d.getMonth()+1 == startMonth) {
        destinations.add(new Destination(timestampMs, lon, lat, acc));
      }
    } else if (byYear && !byMonth) {
      if (d.getYear()+1900 == year) {
        destinations.add(new Destination(timestampMs, lon, lat, acc));
      }
    } else {
      destinations.add(new Destination(timestampMs, lon, lat, acc));
    }
  }
}

void initPlaces() {
  places = new ArrayList<Destination>();
  switch(AGGREGATE_MODE) {
  case AGGREGATE_YEAR:
    initPlaces(true, false, false);
    break;
  case  AGGREGATE_MONTH:
    initPlaces(true, true, false);
    break;
  case  AGGREGATE_DAY:
    initPlaces(true, true, true);
    break;
  default:
    initPlaces(false, false, false);
    break;
  }
}

void initPlaces(boolean byYear, boolean byMonth, boolean byDay) {
  if (byDay) initPlacesByTime(year, startMonth, true);
  else if (byMonth) initPlacesByTime(year, startMonth, false);
  else if (byYear && !byMonth) {
    initPlacesAllYear(year);
  } else {
    for (int yr = 2017; yr <= 2020; yr++) {
      initPlacesAllYear(yr);
    }
  }
}

void initPlacesAllYear(int yr) {
  for (int month = 1; month <= 12; month++) {
    initPlacesByTime(yr, month, false);
  }
}



// jan = 1
void initPlacesByTime(int yr, int mon, boolean byDay) {
  if (yr == 2017 && mon < 6) return;
  else if (yr == 2020 && mon > 3) return;
  JSONObject json = loadJSONObject("originals/" + yr + "/" + yr + "_" + mon + ".json");
  JSONArray timelineObjects = json.getJSONArray("timelineObjects");

  for (int i = 0; i < timelineObjects.size(); i++) {
    JSONObject obj = timelineObjects.getJSONObject(i);
    if (obj.getJSONObject("placeVisit") != null) {
      JSONObject loc = obj.getJSONObject("placeVisit").getJSONObject("location");

      long lat =  loc.getLong("latitudeE7");
      long lon =  loc.getLong("longitudeE7");
      String id = loc.getString("placeId");
      String addr = loc.getString("address");
      String n = loc.getString("name");

      JSONObject dur = obj.getJSONObject("placeVisit").getJSONObject("duration");
      long ts = dur.getLong("startTimestampMs");
      long endts = dur.getLong("endTimestampMs");

      long acc =  obj.getJSONObject("placeVisit").getLong("visitConfidence");

      Date d = new Date(ts);
      if (byDay) {
        if (d.getYear()+1900 == year && d.getDate() == startDay && d.getMonth()+1 == startMonth) {
          places.add(new PlaceVisit(ts, endts, lon, lat, acc, n, addr, id));
        }
      } else places.add(new PlaceVisit(ts, endts, lon, lat, acc, n, addr, id));
    }
  }
}

void initPaths() {
  paths = new ArrayList<ActivityPath>();
  switch(AGGREGATE_MODE) {
  case AGGREGATE_YEAR:
    initPaths(true, false, false);
    break;
  case  AGGREGATE_MONTH:
    initPaths(true, true, false);
    break;
  case  AGGREGATE_DAY:
    initPaths(true, true, true);
    break;
  default:
    initPaths(false, false, false);
    break;
  }
}

void initPaths(boolean byYear, boolean byMonth, boolean byDay) {
  if (byDay) initPathByTime(year, startMonth, true);
  else if (byMonth) initPathByTime(year, startMonth, false);
  else if (byYear && !byMonth) {
    initPathsAllYear(year);
  } else {
    for (int yr = 2017; yr <= 2020; yr++) {
      initPathsAllYear(yr);
    }
  }
}


void initPathsAllYear(int yr) {
  for (int month = 1; month <= 12; month++) {
    initPathByTime(yr, month, false);
  }
}

void initPathByTime(int year, int month, boolean byDay) {
  if (year == 2017 && month < 6) return;
  else if (year == 2020 && month > 3) return;
  JSONObject json = loadJSONObject("originals/" + year + "/" + year + "_" + month + ".json");
  JSONArray timelineObjects = json.getJSONArray("timelineObjects");

  for (int i = 0; i < timelineObjects.size(); i++) {
    JSONObject obj = timelineObjects.getJSONObject(i);
    if (obj.getJSONObject("activitySegment") != null) {
      JSONObject p = obj.getJSONObject("activitySegment");
      JSONObject startLoc = p.getJSONObject("startLocation");
      JSONObject endLoc = p.getJSONObject("endLocation");
      long lat0 =  startLoc.getLong("latitudeE7");
      long lon0 =  startLoc.getLong("longitudeE7");
      long lat1 =  endLoc.getLong("latitudeE7");
      long lon1 =  endLoc.getLong("longitudeE7");

      String activity = p.getString("activityType");

      float distanceMiles = 0;
      try {
        distanceMiles = p.getInt("distance") * 0.000621371;
      }
      catch(Exception e) {
      }

      JSONObject dur = p.getJSONObject("duration");
      long ts = dur.getLong("startTimestampMs");
      long endts = dur.getLong("endTimestampMs");
      float duration = (endts-ts)/1000.0;

      Date d = new Date(ts);


      long[][] coords;


      //try {
      //  JSONArray waypointPath = p.getJSONObject("waypointPath").getJSONArray("waypoints");
      //  coords = new long[waypointPath.size() + 2][2];
      //  coords[0][0] = lat0;
      //  coords[0][1] = lon0;

      //  for (int j = 0; j < waypointPath.size(); j++ ) {
      //    coords[j+1][0] = waypointPath.getJSONObject(j).getLong("latE7");
      //    coords[j+1][1] = waypointPath.getJSONObject(j).getLong("lngE7");
      //  }
      //  coords[coords.length-1][0] = lat1;
      //  coords[coords.length-1][1] = lon1;
      //}
      //catch(Exception e) {
      //  coords = new long[2][2];
      //  coords[0][0] = lat0;
      //  coords[0][1] = lon0;
      //  coords[1][0] = lat1;
      //  coords[1][1] = lon1;
      //}

      coords = new long[2][2];
      coords[0][0] = lat0;
      coords[0][1] = lon0;
      coords[1][0] = lat1;
      coords[1][1] = lon1;

      if ( byDay) {
        if (d.getDate() == startDay) paths.add(new ActivityPath(coords, ts, endts, distanceMiles, activity));
      } else paths.add(new ActivityPath(coords, ts, endts, distanceMiles, activity));
    }
  }
}



void editDestinations() {
  // EDITING / SAVING DESTINATIONS
  JSONArray objs = new JSONArray();
  int index = 0;
  for (int i = 0; i < destinations.size(); i++) {
    if (destinations.get(i).include()) {
      JSONObject json = destinations.get(i).getJSON();
      objs.setJSONObject(index, json);
      index++;
    } else {
      destinations.remove(i);
      i--;
    }
  }
  //saveJSONArray(objs, "data/" + year +".json");
}

void editPlaces() {
  JSONArray objs = new JSONArray();
  int index = 0;
  for (int i = 0; i < places.size(); i++) {
    if (places.get(i).include()) {
      JSONObject json = places.get(i).getJSON();
      objs.setJSONObject(index, json);
      index++;
    } else {
      places.remove(i);
      i--;
    }
  }
  //saveJSONArray(objs, "data/" + year +".json");
  //saveJSONArray(objs, "data/places_" + year +".json");
}

void binDestinations() {
  for (Destination d : destinations) {
    //hexbin.incHex(d.x, d.y);
    tribin.incElevation(d.x, d.y);
  }
}

void binPlaces() {
  for (Destination d : places) {
    //hexbin.incHex(d.x, d.y);
    tribin.incElevationPlaces(d.x, d.y, ((PlaceVisit) d).name);
  }
}

void saveJSON() {
  if (AGGREGATE_MODE == AGGREGATE_YEAR) {
    saveBinJSON(year +"_bins");
    saveBinJSON(year +"_placebins");
  } else if (AGGREGATE_MODE == AGGREGATE_ALL) {
    saveBinJSON("all_bins");
    saveBinJSON("all_placebins");
  }
}

void saveBinJSON(String path) {
  // SAVING BINS
  JSONObject tribinjson = new JSONObject();
  tribinjson.setFloat("size", binSize);
  tribinjson.setInt("r", tribin.r);
  tribinjson.setInt("c", tribin.c);
  tribinjson.setFloat("min", tribin.min);
  tribinjson.setFloat("max", tribin.max);
  JSONArray bins = new JSONArray();
  int index = 0;
  for (int r = 0; r < tribin.elevations.length; r++) {
    for (int c = 0; c < tribin.elevations[0].length; c++) {
      JSONObject obj = new JSONObject();
      obj.setInt("r", r);
      obj.setInt("c", c);
      obj.setFloat("elev", tribin.elevations[r][c]);
      bins.setJSONObject(index, obj);
      index++;
    }
  }
  tribinjson.setJSONArray("bins", bins);
  saveJSONObject(tribinjson, "data/output/" + path + ".json");
}


void displayPaths() {
  for (int i = 0; i < paths.size(); i++) {
    paths.get(i).display();
    //paths.get(i).displayConnections();
  }
}

void displayHUD() {
  cam.beginHUD();
  if (DRAWING_CONTOURS) fill(255);
  else fill(255);
  text(year, 30, 30);
  text("" + nfc(frameRate, 2), 30, 50);
  cam.endHUD();
}
