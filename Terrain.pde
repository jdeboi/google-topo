

float levels = 35;                    // number of contours
float factor = 5;                     // scale factor
float elevation = 105;                 // total height of the 3d model

float colorStart =  0;               // Starting dregee of color range in HSB Mode (0-360)
float colorRange =  160;             // color range / can also be negative


// Array of BlobDetection Instances
BlobDetection[] theBlobDetection = new BlobDetection[int(levels)];

PGraphics contour;

void initContour() {
  contour = createGraphics(tribin.c, tribin.r);
  drawElevationsContour(contour, tribin.elevations);
  initBlob(contour);
}

void initBlob(PGraphics pg) {
  //Computing Blobs with different thresholds 
  pg.loadPixels();
  for (int i=0; i<levels; i++) {
    println("level", i);
    theBlobDetection[i] = new BlobDetection(pg.width, pg.height);
    theBlobDetection[i].setThreshold(i/levels);
    theBlobDetection[i].computeBlobs(pg.pixels);
  }
}

void drawContours(PGraphics pg) {
  fill(255, 0, 0);

  for (int i=0; i<levels; i++) {
    translate(0, 0, (tribin.max-tribin.min)/levels);  
    drawContour(pg, i);
  }
}

void drawContour(PGraphics pg, int i) {
  Blob b;
  EdgeVertex eA, eB;
  for (int n=0; n<theBlobDetection[i].getBlobNb(); n++) {
    b=theBlobDetection[i].getBlob(n);
    if (b!=null) {
      strokeWeight(2);
      //stroke((i/levels*colorRange)+colorStart,100,100);
      stroke(0, 255, 0);
      for (int m=0; m<b.getEdgeNb(); m++) {
        eA = b.getEdgeVertexA(m);
        eB = b.getEdgeVertexB(m);
        if (eA !=null && eB !=null)
          line(
            eA.x*pg.width*factor, eA.y*pg.height*factor, 
            eB.x*pg.width*factor, eB.y*pg.height*factor 
            );
      }
    }
  }
}

void drawElevationsTex(PGraphics pg, float[][] elevations, float sz) {
  //pg.lights();

  pg.textureMode(NORMAL);
  pg.noStroke();
  pg.beginShape(TRIANGLES);
  pg.texture(tex);
  for (int r=0; r<elevations.length-1; r++) {
    for (int c=0; c<elevations[0].length-1; c++) {

      drawVertTex(pg, elevations, r, c, sz);
      drawVertTex(pg, elevations, r+1, c, sz);
      drawVertTex(pg, elevations, r+1, c+1, sz);

      drawVertTex(pg, elevations, r+1, c+1, sz);
      drawVertTex(pg, elevations, r, c+1, sz);
      drawVertTex(pg, elevations, r, c, sz);
    }
  }
  pg.endShape();
}

void drawElevations(PGraphics pg, float[][] elevations, float sz) {
  //pg.lights();

  pg.textureMode(NORMAL);
  pg.noStroke();
  pg.beginShape(TRIANGLES);
  //pg.texture(tex);
  for (int r=0; r<elevations.length-1; r++) {
    for (int c=0; c<elevations[0].length-1; c++) {

      drawVert(pg, elevations, r, c, sz);
      drawVert(pg, elevations, r+1, c, sz);
      drawVert(pg, elevations, r+1, c+1, sz);

      drawVert(pg, elevations, r+1, c+1, sz);
      drawVert(pg, elevations, r, c+1, sz);
      drawVert(pg, elevations, r, c, sz);
    }
  }
  pg.endShape();
}

void drawVert(PGraphics pg, float[][] elevations, int r, int c, float sz) {
  float z = elevations[r][c];
  //pg.fill(color(getZFill(z)));
  pg.fill(getZFillGoogle(z));
  pg.strokeWeight(1);
  float u = map(c, 0, elevations[0].length, 0, 1);
  float v = map(r, 0, elevations.length, 0, 1);

  float y = r*sz;
  float x = c*sz;
  //pg.vertex(x, y, z, u, v);
  pg.vertex(x, y, z);
}

void drawVertTex(PGraphics pg, float[][] elevations, int r, int c, float sz) {
  float z = elevations[r][c];
  pg.noStroke();
  float u = map(c, 0, elevations[0].length, 0, 1);
  float v = map(r, 0, elevations.length, 0, 1);

  float y = r*sz;
  float x = c*sz;
  pg.vertex(x, y, z, u, v);
}

void drawElevationsContour(PGraphics pg, float[][] elevations) {
  pg.beginDraw();
  pg.noStroke();
  pg.beginShape(TRIANGLES);
  for (int r=0; r<elevations.length-1; r++) {
    for (int c=0; c<elevations[0].length-1; c++) {

      drawVertContour(pg, elevations, r, c);
      drawVertContour(pg, elevations, r+1, c);
      drawVertContour(pg, elevations, r+1, c+1);

      drawVertContour(pg, elevations, r+1, c+1);
      drawVertContour(pg, elevations, r, c+1);
      drawVertContour(pg, elevations, r, c);
    }
  }
  pg.endShape();
  pg.endDraw();
}

void drawVertContour(PGraphics pg, float[][] elevations, int r, int c) {


  float val = map(elevations[r][c], tribin.min, tribin.max, 0, 255);
  pg.fill(color(val));
  float y = r;
  float x = c;
  pg.vertex(x, y);
}


color getZFillContour(float z) {
  if (z == 0) return color(0);
  float per;
  if (z < 3) per = map(z, 0, 3, 0, .4*255);
  else if (z < 8) per = map(z, 3, 8, .4*255, .8*255);
  else per = map(z, 8, tribin.max, .8*255, 255);
  constrain(per, 0, 255);
  return color(per);
  //return lerpColor(googleColors[3], googleColors[2], per);
}

color getZFillGoogle(float z) {
  float[] breaks = {
    .04*tribin.max, 
    .12*tribin.max, 
    .2*tribin.max, 
    .5*tribin.max
  };
  if (z == 0) return color(0, 150);
  float per;
  if (z<breaks[0]) return lerpColor(yellowColor, greenColor, map(z, 0, breaks[0], 0, .3));
  else if (z < breaks[1]) return lerpColor( yellowColor, greenColor, map(z, breaks[0], breaks[1], .3, 2 ));
  else if (z < breaks[2]) return lerpColor( greenColor, blueColor, map(z, breaks[1], breaks[2], 0, 4 ));
  else if (z < breaks[3]) return lerpColor( blueColor, redColor, map(z, breaks[2], breaks[3], 0, 4 ));
  return lerpColor( redColor, yellowColor, map(z, breaks[3], tribin.max, 0, 4 ));
}

color getZFill(float z) {
  if (z == 0) return color(0, 150);
  float per;
  if (z<5) return lerpColor(yellowColor, color(255, 0, 0), map(z, 0, 5, 0, 1));
  //else if (z < 15)  per = map(z, 15, 20, 0, .6);
  //else per = map(z, 20, tribin.max, .6, 1);
  //return blueColor;
  //else if (z < 5) per = map(z, 3, 5, 0, .4);
  //else per = map(z, 5, tribin.max, .4, 2);
  //constrain(per, 0, 1);
  per = map(z, 5, tribin.max, 0, 2);
  per = constrain(per, 0, 1);
  return lerpColor( color(255, 0, 0), yellowColor, per );
}


color getZFillOG(float z) {
  if (z == 0) return color(0, 150);
  float per;
  if (z < 3) per = map(z, 0, 3, 0, .4);
  else per = map(z, 3, tribin.max, .4, 2);
  constrain(per, 0, 1);
  return lerpColor( color(255, 0, 0), color(#2647d9), per );
}

import nervoussystem.obj.*;
boolean record;
void recordTerrain(float [][] elevations, float sz) {
  if (record) {
    //export an x3d file, change to OBJExport for obj
    MeshExport x3D = (MeshExport) createGraphics(10, 10, "nervoussystem.obj.OBJExport", "colored.obj");
    x3D.setColor(true);
    x3D.beginDraw();
    drawElevations(x3D, elevations, sz);
    x3D.endDraw();
    x3D.dispose();
    record = false;
  }
}

color yellowColor, blueColor, greenColor, redColor;
void initColors() {
  googleColors = new color[4];
  googleColors[0] = color(#f5b00a); // yellow
  googleColors[1] = color(#27953C); // green
  googleColors[2] = color(#2F65E9); //blue
  googleColors[3] = color(#DB2822); //red

  yellowColor = color(246, 176, 10  );
  blueColor = color(#2647d9);
  greenColor = color(#27953C); 
  redColor = color(#DB2822);
}


PShape[] contours;
void initContours() {
  contours = new PShape[34];
  for (int i = 0; i < contours.length; i++) {
    contours[i] = loadShape("cuts/" + i + ".svg");
  }
}
