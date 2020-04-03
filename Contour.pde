
void displayContours() {
  for (int i = 0; i < contours.length; i++) {
    contours[i].disableStyle();
    PShape sh = contours[i].getChild(1);
    if (sh.getChildCount() > 1) sh = sh.getChild(1);

    //stroke(pulseStroke(500));
    stroke(getWaveStroke(i, 10, -1));
    strokeWeight(1);

    noFill();
    pushMatrix();
    translate(0, 0, i*(tribin.max - tribin.min)/levels);
    shape(sh, 0, 0);
    popMatrix();
  }
}

color getWaveStroke(int i, float block, int direction) {
  float s = sin((i*direction+millis()/300.0)*1.0/block*(2*PI));
  float alpha = map(s, -1, 1, 0, 155) ;
  return color(255, alpha);
}

color getNoiseStroke(int i) {
  float n = noise(i+ millis()/1000.0);
  float alpha = map(n, 0, 1, 0, 255) ;
  alpha = constrain(alpha, 0, 255);
  return color(255, alpha);
}


//color getDripStroke(int i) {
//  if (i > dripIndex) return color(255, 0);
//  float alpha = map(i, dripIndex-10, dripIndex, 0, 255);
//  alpha = constrain(alpha, 0, 255);
//  return color(255, alpha);
//}

color pulseStroke(int delayT) {
  float s = sin(millis()/(1.0*delayT));
  float alpha = map(s, -1, 1, 0, 155);
  return color(255, alpha);
}
