// https://www.redblobgames.com/grids/hexagons/#coordinates

class HexBin {

  float size, w, h;
  Hex[][] bins;

  HexBin(float size) {
    this.size = size;
    float hexw = sqrt(3)*size;
    float hexh = size*2;

    int numC = ceil(width/size);
    int numR = ceil(height/size);

    bins = new Hex[numR][numC];
    for (int r = 0; r < bins.length; r++) {
      for (int c = 0; c < bins[0].length; c++) {
        bins[r][c] = new Hex(size, r, c, hexw, hexh);
      }
    }
  }

  void resetBins() {
    for (int r = 0; r < bins.length; r++) {
      for (int c = 0; c < bins[0].length; c++) {
        bins[r][c].val = 0;
      }
    }
  }

  void displayBins() {
    for (int r = 0; r < bins.length; r++) {
      for (int c = 0; c < bins[0].length; c++) {
        bins[r][c].display();
      }
    }
  }

  void incHex(float xx, float yy) {
    int x = int(xx);
    int y = int (yy);
    int r = xyToHex(size, x, y)[0];
    int c = xyToHex(size, x, y)[1];
    if (c >= 0 && c < bins[0].length && r >= 0 && r < bins.length) {
      bins[r][c].val++;
    }
  }

  void setHex(float val, int x, int y) {
    int r = xyToHex(size, x, y)[0];
    int c = xyToHex(size, x, y)[1];
    if (c >= 0 && c < bins[0].length && r >= 0 && r < bins.length) {
      bins[r][c].val = val;
    }
  }
}


class Hex {
  int c, r;
  float w, h;
  float x, y;
  float size;
  float val;

  Hex(float size, int r, int c, float w, float h) {
    this.size = size;
    this.r = r;
    this.c = c;
    this.w = w;
    this.h = h;
  }

  // pointy?
  void display() {


    //noStroke();
    fill(getFill());

    //noFill();
    stroke(255);
    //noFill();

    pushMatrix();
    PVector loc = hexToXY(size, r, c);
    translate(loc.x-w/2, loc.y-h/2);


    beginShape();
    vertex(0, h/4); // -
    vertex(w/2, 0);
    vertex(w, h/4);
    vertex(w, h*3/4);
    vertex(w/2, h);
    vertex(0, h*3/4);
    vertex(0, h/4);
    endShape();


    popMatrix();
  }

  color getFill() {
    if (val == 0) return color(255, 0);
 
    colorMode(HSB, 100);
    //int vals[] = {1, 2, 3, 4};
    //color c1 = color(255, 0, 0);
    //color c2 = color(255, 255, 0);
    //color c3 = color(0, 255, 0);
    //color c4 = color(0, 255, 255);
    //if (val < vals[0]) lerpColor(c1, c2, map(val, 0, vals[0], 0, 1));
    //else if (val < vals[1]) lerpColor(c2, c3, map(val, vals[0], vals[1], 0, 1));
    //else lerpColor(c3, c4, map(val, vals[1], vals[2], 0, 1));
    //float per = map(val, 0, 15, 0, 1);
    //per = constrain(per, 0, 1);
    //color col = lerpColor(c1, c2, per);
    color col = color(val, 100, 100);
    return color(col, 50);
  }
}

//https://www.redblobgames.com/grids/hexagons/#coordinates
int[] offset_oddr(int x, int y) {
  int col = x + (y - (y&1)) / 2;
  int row = y;
  int [] rc = {row, col};
  return rc;
}



int[] xyToHex(float size, int x, int y) {

  int r = round((2./3 * y) / size);
  int c;
  if (r % 2 == 1) c = round((x-sqrt(3)*size/2)/(sqrt(3)*size) );
  else c = round(x/(sqrt(3)*size) );

  int [] arr = {r, c};
  return arr;
}



PVector hexToXY(float size, int r, int c) {
  float x = size * (sqrt(3) * c  +  sqrt(3)/2 * r);
  float y = size * (3./2 * r);

  // offset
  x -= (r/2)*sqrt(3)*size;
  PVector p = new PVector(x, y);
  return p;
}
