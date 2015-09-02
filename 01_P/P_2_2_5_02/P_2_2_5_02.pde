// P_2_2_5_02.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * pack as many cirlces as possible together
 * 
 * MOUSE
 * press + position x/y : move area of interest
 * 
 * KEYS
 * 1                    : show/hide svg modules
 * 2                    : show/hide lines
 * 3                    : show/hide circles
 * arrow up/down        : resize area of interest
 * f                    : freeze process. on/off
 * s                    : save png
 * p                    : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;
boolean freeze = false;

int maxCount = 5000; //max count of the cirlces
int currentCount = 1;
float[] x = new float[maxCount];
float[] y = new float[maxCount];
float[] r = new float[maxCount]; //radius
int[] closestIndex = new int[maxCount]; //index

float minRadius = 3;
float maxRadius = 50;

// mouse and arrow up/down interaction
float mouseRect = 30;

// svg vector import
PShape module1, module2;

// style selector, hotkeys 1,2,3
boolean showSvg = true;
boolean showLine = false;
boolean showCircle = false;

void setup() {
  size(800, 800);
  noFill();
  smooth();
  cursor(CROSS);

  module1 = loadShape("01.svg");
  module2 = loadShape("02.svg");

  // first circle
  x[0] = 200;
  y[0] = 100;
  r[0] = 50;
  closestIndex[0] = 0;
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  shapeMode(CENTER);
  ellipseMode(CENTER);
  background(255);

  for (int j = 0; j < 40; j++) {
    // create a random position
    float tx = random(0+maxRadius,width-maxRadius);
    float ty = random(0+maxRadius,height-maxRadius);
    float tr = minRadius;

    // create a random position according to mouse position
    if (mousePressed == true) {
      tx = random(mouseX-mouseRect/2,mouseX+mouseRect/2);
      ty = random(mouseY-mouseRect/2,mouseY+mouseRect/2);
      tr = 1;
    } 

    boolean insection = true;
    // find a pos with no intersection with others circles
    for(int i=0; i < currentCount; i++) {
      float d = dist(tx,ty, x[i],y[i]);
      //println(d);
      if (d >= (tr + r[i])) insection = false;     
      else {
        insection = true; 
        break;
      }
    }

    // stop process by pressing hotkey 'F'
    if (freeze) insection = true;

    // no intection ... add a new circle
    if (insection == false) {
      // get closest neighbour and closest possible radius
      float tRadius = width;
      for(int i=0; i < currentCount; i++) {
        float d = dist(tx,ty, x[i],y[i]);
        if (tRadius > d-r[i]) {
          tRadius = d-r[i];
          closestIndex[currentCount] = i;
        }
      }

      if (tRadius > maxRadius) tRadius = maxRadius;

      x[currentCount] = tx;
      y[currentCount] = ty;
      r[currentCount] = tRadius;
      currentCount++;
    }
  }

  // draw them
  for (int i=0 ; i < currentCount; i++) {
    pushMatrix();
    translate(x[i],y[i]);
    // we abuse radius as random angle :)
    rotate(radians(r[i]));

    if (showSvg) {
      // draw SVGs
      if (r[i] == maxRadius) shape(module1, 0, 0, r[i]*2,r[i]*2);
      else shape(module2, 0, 0, r[i]*2,r[i]*2);
    }
    if (showCircle) {
      // draw circles
      stroke(0);
      strokeWeight(1.5);
      ellipse(0,0, r[i]*2,r[i]*2);
    }
    popMatrix();

    if (showLine) {
      // draw connection-lines to the nearest neighbour
      stroke(150);
      strokeWeight(1);
      int n = closestIndex[i];
      line(x[i],y[i], x[n],y[n]); 
    }
  } 

  // visualize the random range of the new positions
  if (mousePressed == true) {
    stroke(255,200,0);
    strokeWeight(2);
    rect(mouseX-mouseRect/2,mouseY-mouseRect/2,mouseRect,mouseRect);
  } 

  if (currentCount >= maxCount) noLoop();

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  // freeze process, toggle on/off
  if (key == 'f' || key == 'F') freeze = !freeze;

  // skin style, toggle on/off
  if (key == '1') showSvg = !showSvg;
  if (key == '2') showLine = !showLine;
  if (key == '3') showCircle = !showCircle;
}

void keyPressed() {
  // mouseRect ctrls arrowkeys up/down 
  if (keyCode == UP) mouseRect += 4;
  if (keyCode == DOWN) mouseRect -= 4; 
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}