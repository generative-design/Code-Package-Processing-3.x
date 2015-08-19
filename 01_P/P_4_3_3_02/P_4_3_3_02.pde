// P_4_3_3_02.pde
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
 * generating a drawing with 3 brushes by analysing live video
 * 
 * KEYS
 * q                   : stop drawing
 * w                   : continue drawing
 * s                   : save png
 * r                   : start record pdf
 * e                   : end record pdf
 *
 */

import processing.pdf.*;
import processing.video.*;
import java.util.Calendar;

boolean savePDF = false;

Capture video;

int pixelIndex;
color c;

float x1, x2, x3, y1, y2, y3;
float curvePointX = 0; 
float curvePointY = 0;

int counter;
int maxCounter = 100000;

void setup() {
  size(640, 480);
  video = new Capture(this, width, height, 30);
  video.start();
  background(255);
  x1 = 0;
  y1 = height/2;
  x2 = width/2;
  y2 = 0;
  x3 = width;
  y3 = height/2;
}

void draw() {
  colorMode(HSB, 360, 100, 100);
  smooth();
  noFill();

  // get actual web cam image
  if (video.available()) video.read();
  video.loadPixels();


  // first line
  pixelIndex = (int) ((video.width-1-int(x1)) + int(y1)*video.width);
  c = video.pixels[pixelIndex];
  float hueValue = hue(c);
  strokeWeight(hueValue/50);
  stroke(c);

  beginShape();
  curveVertex(x1, y1);
  curveVertex(x1, y1);
  for (int i = 0; i < 7; i++) {
    curvePointX = constrain(x1+random(-50, 50), 0, width-1);
    curvePointY = constrain(y1+random(-50, 50), 0, height-1);
    curveVertex(curvePointX, curvePointY);
  }
  curveVertex(curvePointX, curvePointY);
  endShape();
  x1 = curvePointX;
  y1 = curvePointY;


  // second line
  pixelIndex = (int) ((video.width-1-int(x2)) + int(y2)*video.width);
  c = video.pixels[pixelIndex];
  float saturationValue = saturation(c);
  strokeWeight(saturationValue/2);
  stroke(c);

  beginShape();
  curveVertex(x2, y2);
  curveVertex(x2, y2);
  for (int i = 0; i < 7; i++) {
    curvePointX = constrain(x2+random(-50, 50), 0, width-1);
    curvePointY = constrain(y2+random(-50, 50), 0, height-1);
    curveVertex(curvePointX, curvePointY);
  }
  curveVertex(curvePointX, curvePointY);
  endShape();
  x2 = curvePointX;
  y2 = curvePointY;


  // third line
  pixelIndex = (int) ((video.width-1-int(x3)) + int(y3)*video.width);
  c = video.pixels[pixelIndex];
  float brightnessValue = brightness(c);
  strokeWeight(brightnessValue/100);
  stroke(c);

  beginShape();
  curveVertex(x3, y3);
  curveVertex(x3, y3);
  for (int i = 0; i < 7; i++) {
    curvePointX = constrain(x3+random(-50, 50), 0, width-1);
    curvePointY = constrain(y3+random(-50, 50), 0, height-1);
    curveVertex(curvePointX, curvePointY);
  }
  curveVertex(curvePointX, curvePointY);
  endShape();
  x3 = curvePointX;
  y3 = curvePointY;


  counter++;
  if (counter>=maxCounter) noLoop();
}

void keyPressed(){
  switch(key){
  case BACKSPACE:
    background(360);
    break;
  }
}

void keyReleased(){
  if (key == 's'){  
    saveFrame(timestamp()+"_##.png");
  }
  if (key == 'r'){  
    background(360);
    beginRecord(PDF, timestamp()+".pdf");
  }
  if (key == 'e'){  
    endRecord();
  }
  if (key == 'q'){  
    noLoop();
  }
  if (key == 'w'){  
    loop();
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}







