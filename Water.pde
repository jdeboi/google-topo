class Terrain {
  float[][]elevations;

  float movingTerr = 0;
  float movingTerrInc = 0.005;
  boolean movingTerrOn = true;
  float xoffInc = 0.2;
  int rows, cols;
  int spacing;

  int minTerrain = -10;
  int maxTerrain = 10;


  Terrain(int spacing) {
    int w = width;
    int h = height;

    this.spacing = spacing;
    this.cols = ceil(w*1.0/spacing)+1;
    this.rows = ceil(h*1.0/spacing)+1;

    elevations = new float [rows][cols];

    setNoise();
  }

  void display(float waterY) {
    setNoise();

    pushMatrix();
    translate(cols*spacing/2.0, rows*spacing/2.0, waterY);

    noStroke();
    //stroke(255);


    translate(-this.cols*this.spacing/2, -this.rows*this.spacing/2);
    for (int r = 0; r < this.rows-1; r++) {

      beginShape(TRIANGLE_STRIP);
      for (int c = 0; c < this.cols; c++) {
        fill(getGridFill(r, c));
        vertex(c * this.spacing, r * this.spacing, this.elevations[r][c]);

        fill(getGridFill(r+1, c));
        vertex(c * this.spacing, (r+1) * this.spacing, this.elevations[r+1][c]);
      }
      endShape();
    }
    popMatrix();
  }

  color getGridFill(int r, int c) {
    return color(blueColor, 220);
  }

  void setNoise() {
    movingTerr -= movingTerrInc;

    float yoff = movingTerr;

    for (int r = 0; r < rows; r++) {
      float xoff = 0;
      for (int c = 0; c < cols; c++) {
        elevations[r][c] = map(noise(xoff, yoff), 0, 1, minTerrain, maxTerrain);
        xoff += xoffInc;
      }
      yoff += xoffInc;
    }
  }
}
