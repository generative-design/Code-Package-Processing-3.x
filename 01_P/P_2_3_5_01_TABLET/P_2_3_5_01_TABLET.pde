// P_2_3_5_01_TABLET.pde
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
 * draw tool. shows how to draw with dynamic elements.
 * works only with an external tablet device!
 * 
 * MOUSE
 * drag                : draw
 *
 * TABLET
 * pressure            : saturation (in draw mode 3 only)
 * azimuth             : rotation of each element
 * altitude            : length of each element
 * 
 * KEYS
 * 1-3                 : draw mode
 * 6-0                 : colors
 * del, backspace      : clear screen
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;

Tablet tablet;

boolean recordPDF = false;

int drawMode = 1;
color back = color(255);

color fromColor = color(181, 157, 0);
color toColor = color(181, 157, 0);


void setup() {
  size(1280,960);
  smooth();
  tablet = new Tablet(this); 
  background(back);  
  frameRate(30);
  /*
  // load an image in background
   PImage img = loadImage(selectInput("select a background image"));
   image(img, 0, 0, width, height);
   */
}

void draw() {
  // gamma values optimized for wacom intuos 3
  float pressure = gamma(tablet.getPressure(), 2.5);
  float angle = tablet.getAzimuth();
  float penLength = cos(tablet.getAltitude());

  if (pressure > 0.0 && penLength > 0.0) {
    pushMatrix();
    translate(mouseX,mouseY);
    rotate(angle);

    float elementLength = penLength*250;
    float h1 = random(10)*(1.2+penLength);
    float h2 = (-10+random(10))*(1.2+penLength);

    switch(drawMode) {
    case 1:
      stroke(255);
      strokeWeight(0.5); 
      fill(0);
      break;
    case 2:
      stroke(255);
      strokeWeight(0.5);
      //noStroke(); 
      color white = color(255, 20);
      color interColor = lerpColor(fromColor, toColor, random(0,1));
      fill(lerpColor(white, interColor, pressure));
      break;
    case 3:
      color julia = int(map(pressure, 0,1, 0,255));
      fill(0, julia);
      stroke(255);
      strokeWeight(0.5); 
      elementLength = penLength*50;
      h1 = random(5)+elementLength/2;
      h2 = (random(5)+elementLength/2)*-1;
      break;
    }

    float[] pointsX = new float[5];
    float[] pointsY = new float[5];

    pointsX[0] = 0; 
    pointsY[0] = 0;
    pointsX[1] = elementLength*0.77; 
    pointsY[1] = h1;
    pointsX[2] = elementLength; 
    pointsY[2] = 0; 
    pointsX[3] = elementLength*0.77; 
    pointsY[3] = h2;
    pointsX[4] = 0; 
    pointsY[4] = -5;

    beginShape();
    // start controlpoint
    curveVertex(pointsX[3],pointsY[3]); 
    // only these points are drawn
    for (int i=0; i< pointsX.length; i++) {
      curveVertex(pointsX[i],pointsY[i]);  
    }
    // end controlpoint
    curveVertex(pointsX[1],pointsY[1]); 
    endShape(CLOSE);
    popMatrix();
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(back);

  // switch drawing styles
  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key == '3') drawMode = 3;

  if (key == '6') {
    fromColor = color(181, 157, 0);
    toColor = color(181, 157, 0);
  }
  if (key == '7') {
    fromColor = color(0, 130, 164, 20);
    toColor = color(0, 130, 164, 20);
  }
  if (key == '8') {
    fromColor = color(87, 35, 129);
    toColor = color(87, 35, 129);
  }
  if (key == '9') {
    fromColor = color(197, 0, 123);
    toColor = color(197, 0, 123);
  }
  if (key == '0') {
    fromColor = color(0, 130, 164);
    toColor = color(87, 35, 129);
  }

  // ------ pdf export ------
  // press 'r' to start pdf recordPDF and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(back); 
    }
  } 
}

// gamma ramp, non linaer mapping ...
float gamma(float theValue, float theGamma) {
  return pow(theValue, theGamma);
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}





























































