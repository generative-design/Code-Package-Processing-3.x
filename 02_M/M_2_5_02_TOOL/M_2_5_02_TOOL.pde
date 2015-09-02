// M_2_5_02_TOOL.pde
// GUI.pde
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
 * explore different parameters of drawing lissajous figures 
 *
 * KEYS
 * m                   : menu open/close
 * s                   : save png
 * p                   : save pdf
 */


// ------ imports ------

import processing.pdf.*;
import java.util.Calendar;


// ------ initial parameters and declarations ------

int pointCount = 1500;
PVector[] lissajousPoints = new PVector[0];

int freqX = 13;
int freqY = 11;
float phi = 97;

int modFreqX = 0;
int modFreqY = 0;

int modFreq2X = 11;
int modFreq2Y = 17;
float modFreq2Strength = 0.0;

float randomOffset = 2;

boolean invertBackground = false;
float lineWeight = 1;
float lineAlpha = 20;

boolean connectAllPoints = true;
float connectionRadius = 110;
int i1 = 0;
float minHueValue = 0;
float maxHueValue = 100;
float saturationValue = 80;
float brightnessValue = 0;
boolean invertHue = false;


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
boolean guiEvent = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;
Bang[] bangs;


// ------ image output ------

boolean saveOneFrame = false;
boolean savePDF = false;



void setup() {
  size(800, 800);
  //size(760, 1100);
  smooth();
  background(255);

  setupGUI();

  calculateLissajousPoints();
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  colorMode(RGB, 255, 255, 255, 100);
  strokeWeight(lineWeight);
  stroke(0, lineAlpha);
  strokeCap(ROUND);
  noFill();

  color bgColor = color(255);
  if (invertBackground) {
    bgColor = color(0);
  } 

  // calculate points whenever something has changed via the gui and start drawing again
  if (guiEvent || saveOneFrame || savePDF || i1 == 0) {
    calculateLissajousPoints();
    background(bgColor);
    i1 = 0; 
    guiEvent = false;
  }


  if (!connectAllPoints) {
    background(bgColor);

    // simple drawing method
    colorMode(HSB, 360, 100, 100, 100);

    for (int i=0; i<=pointCount-1; i++) {
      drawLine(lissajousPoints[i], lissajousPoints[i+1]);
      i1++;
    }
  } 
  else {
    // drawing method where all points are connected with each other
    // alpha depends on distance of the points  

    // draw lines not all at once, just the next 100 milliseconds to keep performance
    int drawEndTime = millis() + 100;
    if (saveOneFrame || savePDF) {
      drawEndTime = Integer.MAX_VALUE;
    }

    colorMode(HSB, 360, 100, 100, 100);
    while (i1 < pointCount && millis () < drawEndTime) {
      for (int i2 = 0; i2 < i1; i2++) {
        drawLine(lissajousPoints[i1], lissajousPoints[i2]);
      }
      i1++;

      if (savePDF) {
        println("saving to pdf – step " + i1 + "/" + pointCount);
      }
    }
  }

  // image output
  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
    println("saving to pdf – done");
  }

  if (saveOneFrame) {
    saveFrame(timestamp()+".png");
  }

  // draw gui
  drawGUI();

  // image output
  if (saveOneFrame) {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    saveOneFrame = false;
  }
}


void calculateLissajousPoints() {
  if (pointCount != lissajousPoints.length-1) {
    lissajousPoints = new PVector[pointCount+1];
  }

  randomSeed(0);

  float t, x, y, rx, ry;

  for (int i=0; i<=pointCount; i++) {
    float angle = map(i, 0, pointCount, 0, TWO_PI);

    // an additional modulation of the osscillations
    float fmx = sin(angle*modFreq2X) * modFreq2Strength + 1;
    float fmy = sin(angle*modFreq2Y) * modFreq2Strength + 1;

    x = sin(angle * freqX * fmx + radians(phi)) * cos(angle * modFreqX);
    y = sin(angle * freqY * fmy) * cos(angle * modFreqY);

    rx = random(-randomOffset, randomOffset);
    ry = random(-randomOffset, randomOffset);

    x = (x * (width/2-30-randomOffset) + width/2) + rx;
    y = (y * (height/2-30-randomOffset) + height/2) + ry;

    lissajousPoints[i] = new PVector(x, y);
  }
}


void drawLine(PVector p1, PVector p2) {
  float d, a, h;

  d = PVector.dist(p1, p2);
  a = pow(1/(d/connectionRadius+1), 6);

  if (d <= connectionRadius) {
    if (!invertHue) {
      h = map(a, 0, 1, minHueValue, maxHueValue) % 360;
    } 
    else {
      h = map(1-a, 0, 1, minHueValue, maxHueValue) % 360;
    }
    stroke(h, saturationValue, brightnessValue, a*lineAlpha + (i1%2 * 2));
    line(p1.x, p1.y, p2.x, p2.y);
  }
}



void keyPressed() {

  if (key=='m' || key=='M') {
    GUI = controlP5.getGroup("menu").isOpen();
    GUI = !GUI;
    guiEvent = true;
  }
  if (GUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();

  if (key=='s' || key=='S') {
    saveOneFrame = true;
  }
  if (key=='p' || key=='P') {
    savePDF = true; 
    saveOneFrame = true; 
    println("saving to pdf - starting");
  }
}

void mouseReleased() {
  guiEvent = false;
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}
































