// M_2_5_01.pde
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
 * draw lissajous figures with all points connected
 *
 * KEYS
 * 1/2               : frequency x -/+ 
 * 3/4               : frequency y -/+ 
 * arrow left/right  : phi -/+
 * 7/8               : modulation frequency x -/+
 * 9/0               : modulation frequency y -/+
 * s                 : save png
 * p                 : save pdf
 */


// ------ imports ------

import processing.pdf.*;
import java.util.Calendar;


// ------ initial parameters and declarations ------

int pointCount = 1000;
PVector[] lissajousPoints = new PVector[0];

int freqX = 4;
int freqY = 7;
float phi = 15;

int modFreqX = 3;
int modFreqY = 2;

float lineWeight = 1;
color lineColor = color(0);
//color lineColor = color(0, 130, 164);
float lineAlpha = 50;

float connectionRadius = 100;
float connectionRamp = 6;



void setup() {
  size(800, 800);
  smooth();

  calculateLissajousPoints();
  drawLissajous();
}


void draw() {
}


void calculateLissajousPoints() {
  lissajousPoints = new PVector[pointCount+1];

  for (int i=0; i<=pointCount; i++) {
    float angle = map(i, 0,pointCount, 0,TWO_PI);

    float x = sin(angle * freqX + radians(phi)) * cos(angle * modFreqX);
    float y = sin(angle * freqY) * cos(angle * modFreqY);

    x = x * (width/2-30);
    y = y * (height/2-30);

    lissajousPoints[i] = new PVector(x, y);
  }
}


void drawLissajous() {
  float d, a, h;

  colorMode(RGB, 255, 255, 255, 100);
  background(255);
  strokeWeight(lineWeight);
  strokeCap(ROUND);
  noFill();

  pushMatrix();
  translate(width/2, height/2);

  for (int i1 = 0; i1 < pointCount; i1++) {
    for (int i2 = 0; i2 < i1; i2++) {
      PVector p1 = lissajousPoints[i1];
      PVector p2 = lissajousPoints[i2];

      d = PVector.dist(p1, p2);
      a = pow(1/(d/connectionRadius+1), 6);

      if (d <= connectionRadius) {
        stroke(lineColor,  a*lineAlpha);
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
  popMatrix();
}





void keyPressed(){
  if(key == 's' || key == 'S') saveFrame(timestamp()+".png");

  if(key == 'p' || key == 'P') {
    println("saving to pdf - starting");
    //beginRecord(PDF, timestamp()+".pdf");
    beginRecord(PDF, freqX+"_"+freqY+"_"+int(phi)+"_"+modFreqX+"_"+modFreqY+".pdf");

    drawLissajous();

    println("saving to pdf – finishing");
    endRecord();
    println("saving to pdf – done");
  }

  if(key == '1') freqX--;
  if(key == '2') freqX++;
  freqX = max(freqX, 1);

  if(key == '3') freqY--;
  if(key == '4') freqY++;
  freqY = max(freqY, 1);

  if (keyCode == LEFT) phi -= 15;
  if (keyCode == RIGHT) phi += 15;
  
  if(key == '7') modFreqX--;
  if(key == '8') modFreqX++;
  modFreqX = max(modFreqX, 1);
  
  if(key == '9') modFreqY--;
  if(key == '0') modFreqY++;
  modFreqY = max(modFreqY, 1);

  calculateLissajousPoints();
  drawLissajous();

  println("freqX: " + freqX + ", freqY: " + freqY + ", phi: " + phi + ", modFreqX: " + modFreqX + ", modFreqY: " + modFreqY); 
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}




































