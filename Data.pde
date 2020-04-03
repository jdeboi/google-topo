color[] googleColors;

void smoothElevations(float[][] elevations, int smoothD) {
  float[][] smoothed = new float[elevations.length][elevations[0].length];
  for (int r=smoothD; r<elevations.length-smoothD; r++) {
    for (int c=smoothD; c<elevations[0].length-smoothD; c++) {

      smoothed[r][c] = getSmoothedAve(elevations, smoothD, r, c);
    }
  }
  for (int r=0; r<elevations.length; r++) {
    for (int c=0; c<elevations[0].length; c++) {
      elevations[r][c] = smoothed[r][c];
    }
  }
}

void multiplyElevations(float[][] elevations, float mult) {
  for (int r=0; r<elevations.length; r++) {
    for (int c=0; c<elevations[0].length; c++) {
      elevations[r][c] *= mult;
    }
  }
}

float getSmoothedAve(float[][] elevations, int d, int row, int col) {
  if (row - d >=0 && row+d < elevations.length && col - d >= 0 && col + d < elevations[0].length) {
    float ave = 0;
    float div = 0;
    for (int r=row-d; r<=row+d; r++) {
      for (int c=col-d; c<=col+d; c++) {
        //if ((r == row - d && c == col-d) || (r == row-d && c == col+d) || (r == row +d || col == col + d) || (r==row+d && c == col-d));
        //else {
        //  ave += elevations[r][c];
        //  div++;
        //}
        
        // circle?

        int dr = r - (row-d);
        int dc = c - (col-d);
        if (withinSmoothCircle(dr, dc, d)) {
          float dis = dist(dr, dc, d, d);
          float weight = map(dis, 0, d, 1, .5);
          ave += elevations[r][c]*weight;
          div += weight;
        }
      }
    }
     return ave / div;
  }
  return elevations[row][col];
}

boolean withinSmoothCircle(int dr, int dc, int rad) {
  float dis = dist(dr, dc, rad, rad);
  return int(dis) <= rad;
}

// float noiseScale = .5;
void addNoise(float[][] elevations, float amt, float noiseScale) {
  for (int r=0; r<elevations.length; r++) {
    for (int c=0; c<elevations[0].length; c++) {
      float noisez = noise(r*noiseScale, c*noiseScale);
      if (elevations[r][c] > 0) 
        elevations[r][c] += noisez *amt;
    }
  }
}

void logElevations(float[][] elevations) {
  for (int r=0; r<elevations.length; r++) {
    for (int c=0; c<elevations[0].length; c++) {
      float z = elevations[r][c];
      if (z > 0) {
        z = log(z);
        //println(z);
        //z = map(z, 0, 10, 1, 30); //20, 30
        z = map(z, 0, 4, 1, 30);
        elevations[r][c] = z;
      }
    }
  }
}

import java.util.Collections;

class ActivityStop implements Comparable<ActivityStop> {
  String id;
  float num;
  int r, c;

  ActivityStop(String id, float num, int r, int c) {
    this.id = id;
    this.num = num;
    this.r = r;
    this.c = c;
  }

  void display(int sz) {
    float factor = .4;
    if (sz == 0) factor = .7;
    else factor = map(sz, 1, 3, .5, .3);
    int[] xy = tribin.binToPix(r, c); 
    pushMatrix();
    translate(xy[0], xy[1], tribin.elevations[r][c]+3*sin(millis()/300.0));
    translate(-marker.width*factor/2, 0, marker.height*factor);

    //if (sz == 0) stroke(yellowColor);
    //else if (sz ==1) stroke(255, 0, 0);
    //else if (sz ==2) stroke(greenColor);
    //else stroke(yellowColor);
    stroke(yellowColor);
    fill(0, 80);
    strokeWeight(2.5);
    rotateX(-PI/2);
    rotateY(cam.getRotations()[1]);
    //println(cam.getRotations());
    //ellipse(0, 0, 30, 30);

    marker.disableStyle();
    shape(marker, 0, 0, marker.width*factor, marker.height*factor);
    popMatrix();
  }

  @Override
    public int compareTo(ActivityStop o) {
    Float f1 = num;
    Float f2 = o.num;
    return f2.compareTo(f1);
  }

  @Override
    public String toString() {
    return this.id + " " + this.num;
  }
}

void setPopularPlaces() {
  activityStops = new ArrayList<ActivityStop>();
  for (int r = 0; r < tribin.elevationPlaces.length; r++) {
    for (int c = 0; c < tribin.elevationPlaces.length; c++) {
      if (tribin.elevationPlaces[r][c] > 0) {
        activityStops.add(new ActivityStop(tribin.names[r][c], tribin.elevationPlaces[r][c], r, c));
      }
    }
  }

  Collections.sort(activityStops);

  //println(activities);
}

void displayMarkers() {
  activityStops.get(0).display(0);
  for (int i = 1; i  < 10; i++) {
    activityStops.get(i).display(1);
  }

  for (int i = 10; i < 20; i++) {
    activityStops.get(i).display(2);
  }
  for (int i = 20; i < 35; i++) {
    activityStops.get(i).display(3);
  }
}
