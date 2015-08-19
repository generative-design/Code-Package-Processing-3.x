// M_2_2_01.pde
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
 * draws a lissajous curve
 *
 * KEYS
 * a                 : toggle oscillation animation
 * 1/2               : frequency x -/+
 * 3/4               : frequency y -/+
 * arrow left/right  : phi -/+
 * s                 : save png
 * p                 : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int pointCount = 600;
int freqX = 1;
int freqY = 2;
float phi = 90;

float angle;
float x, y; 
float factorX, factorY;

boolean doDrawAnimation = true;

int margin = 25;



void setup() {
  size(600, 600);
  smooth();
}


void draw() {
  // if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  if (savePDF) beginRecord(PDF, freqX+"_"+freqY+"_"+int(phi)+".pdf");

  background(255);
  stroke(0);
  strokeWeight(1);

  if (doDrawAnimation) {
    translate(width*3/4.0, height*3/4.0);
    factorX = width/4-margin;
    factorY = height/4-margin;
  } 
  else {
    translate(width/2, height/2);
    factorX = width/2-margin;
    factorY = height/2-margin;
  }

  beginShape();
  for (int i=0; i<=pointCount; i++){
    angle = map(i, 0,pointCount, 0,TWO_PI);

    x = sin(angle*freqX + radians(phi));
    y = sin(angle*freqY);

    x = x * factorX;
    y = y * factorY;

    vertex(x, y);
  }
  endShape();

  if (doDrawAnimation) {
    drawAnimation();
  }


  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}


void drawAnimation() {
  
  pushStyle();
  noFill();

  // draw x oscillator
  stroke(0);
  beginShape();
  for (int i=0; i<=pointCount; i++){
    angle = map(i, 0,pointCount, 0,TWO_PI);
    x = sin(angle*freqX + radians(phi));
    x = x * (width/4-margin);
    y = -height*2/3.0-margin + (float)i/pointCount * (height/2-2*margin);
    vertex(x, y);
  }
  endShape();

  // draw y oscillator
  stroke(0);
  beginShape();
  for (int i=0; i<=pointCount; i++){
    angle = map(i, 0,pointCount, 0,TWO_PI);
    y = sin(angle*freqY);
    y = y * (height/4-margin);
    x = -width*2/3.0-margin + (float)i/pointCount * (width/2-2*margin);
    vertex(x, y);
  }
  endShape();


  angle = map(frameCount, 0,pointCount, 0,TWO_PI);
  x = sin(angle*freqX + radians(phi));
  y = sin(angle*freqY);
  x = x * (width/4-margin);
  y = y * (height/4-margin);

  float oscYx = -width*2/3.0-margin + (angle/TWO_PI)%1 * (width/2-2*margin);
  float oscXy = -height*2/3.0-margin + (angle/TWO_PI)%1 * (height/2-2*margin);

  stroke(0, 80);
  line(x, oscXy, x, y);
  line(oscYx, y, x, y);

  fill(0);
  stroke(255);
  strokeWeight(2);

  ellipse(x, oscXy, 8, 8);
  ellipse(oscYx, y, 8, 8);

  ellipse(x, y, 10, 10);

  popStyle();
}



void keyPressed(){
  if(key == 's' || key == 'S') saveFrame(timestamp()+".png");
  if(key == 'p' || key == 'P') {
    savePDF = true; 
    println("saving to pdf - starting");
  }

  if (key == 'a' || key == 'A') doDrawAnimation = !doDrawAnimation;

  if(key == '1') freqX--;
  if(key == '2') freqX++;
  freqX = max(freqX, 1);

  if(key == '3') freqY--;
  if(key == '4') freqY++;
  freqY = max(freqY, 1);

  if (keyCode == LEFT) phi -= 15;
  if (keyCode == RIGHT) phi += 15;

  println("freqX: " + freqX + ", freqY: " + freqY + ", phi: " + phi); 
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}




















