class TriBin {


  float[][] elevations;
  float[][] elevationPlaces;
  String[][] names;
  int r, c;
  float sz;

  float min, max;

  TriBin(float sz) {
    this.sz = sz;
    c = ceil(width/sz);
    r = ceil(height/sz);
    elevations = new float[r][c];
    elevationPlaces = new float[r][c];
    names = new String[r][c];
    resetBins();
  }

  void resetBins() {
    for (int r = 0; r < elevations.length; r++) {
      for (int c = 0; c < elevations[0].length; c++) {
        elevations[r][c] = 0;
        elevationPlaces[r][c] = 0;
        names[r][c] = "";
      }
    }
  }




  void displayBins() {

    for (int r = 0; r < elevations.length; r++) {
      for (int c = 0; c < elevations[0].length; c++) {
        int[] point = binToPix(r, c);

        int[] point2 = binToPix(r+1, c+1);
        stroke(255);
        strokeWeight(1);
        noFill();
        //noFill();
        // r, c; r+1, c; r+1, c+1
        //triangle(point[0], point[1], point2[0], point[1], point2[0], point2[1]);
        //// r+1, c+1; r, c+1; r, c
        //triangle(point2[0], point2[1], point[0], point2[1], point[0], point[1]);

        //if (elevations[r][c] > 0) {
        float s = map(elevations[r][c], 0, 50, 0, 100);
        s = constrain(s, 0, 100);
        color col = color(10*elevations[r][c], 0, 255, 150);
        fill(col);
        noStroke();
        ellipse(point[0], point[1], s, s);
        //fill(255, 0, 0);
        //ellipse(width/2, height/2, 30, 30);


        //}
      }
    }
  }

  void displayPlaceBins() {

    for (int r = 0; r < elevationPlaces.length; r++) {
      for (int c = 0; c < elevationPlaces[0].length; c++) {
        int[] point = binToPix(r, c);
        int[] point2 = binToPix(r+1, c+1);
        stroke(255);
        strokeWeight(1);
        noFill();
        float s = map(elevationPlaces[r][c], 0, 5, 0, 50);
        if (elevationPlaces[r][c] > 5) s = map(elevationPlaces[r][c], 5, 30, 0, 100);
        s = constrain(s, 0, 100);
        color col = color(0, 40+10*elevationPlaces[r][c], 0, 150);
        fill(col);
        stroke(255);
        rect(point[0], point[1], s, s);

        fill(255);
        text(names[r][c], point[0], point[1]);
      }
    }
  }

  void setStats() {
    max = 0; 
    min = 1000;
    float ave = 0;
    float aveOver1 = 0;
    int aveOver1Num = 0;
    for (int r = 0; r < elevations.length; r++) {
      for (int c = 0; c < elevations[0].length; c++) {
        if (elevations[r][c] > max) max = elevations[r][c];
        if (elevations[r][c] < min) min = elevations[r][c];
        ave += elevations[r][c];
        if (elevations[r][c] > 0) {
          aveOver1 += elevations[r][c];
          aveOver1Num++;
        }
      }
    }
    println("max:", max);
    println("ave:", ave/(elevations.length*elevations[0].length));
    println("ave over one:", aveOver1/aveOver1Num);
  }

  int[] binToPix(int r, int c) {
    int x = int(c*sz);
    int y = int(r*sz);
    int [] arr = {x, y};
    return arr;
  }


  int[] pixToBins(int x, int y) {
    int c = int(x/sz);
    int r = int(y/sz);
    int[] arr = {r, c};
    return arr;
  }

  void incElevation(float x, float y) {

    int[] rc = pixToBins(int(x), int(y));
    int r= rc[0];
    int c = rc[1];
    elevations[r][c]++;
  }

  void incElevationPlaces(float x, float y, String id) {

    int[] rc = pixToBins(int(x), int(y));
    int r= rc[0];
    int c = rc[1];
    elevationPlaces[r][c]++;
    if (id != null) names[r][c] = id;
  }
}

void setTerrain(float[][] elevations) {
  multiplyElevations(elevations, 5);
  logElevations(elevations);
  smoothElevations(elevations, 3);
  multiplyElevations(elevations, 5);
  addNoise(elevations, 3, .5);
}
