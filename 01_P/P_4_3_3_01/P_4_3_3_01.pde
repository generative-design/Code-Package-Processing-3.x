// P_4_3_3_01.pde
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
 * generating a drawing by analysing live video
 * 
 * MOUSE
 * position x          : drawing speed
 * position y          : diffusion
 *
 * KEYS
 * arrow up            : number of curve points +
 * arrow down          : number of curve points -
 * q                   : stop drawing
 * w                   : continue drawing
 * s                   : save png
 * r                   : start record pdf
 * e                   : end record pdf
 *
 */

import processing.video.*;
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

Capture video;

int x, y;
int curvePointX = 0; 
int curvePointY = 0;
int pointCount = 1;
float diffusion = 50;


void setup() {
  size(640, 480);
  background(255);
  x = width/2;
  y = height/2;
  video = new Capture(this, width, height, 30);
  video.start();
}


void draw() {
  colorMode(HSB, 360, 100, 100);
  smooth();
  noFill();

  for (int j=0; j<=mouseX/50; j++) {
    // get actual web cam image
    if (video.available()) video.read();
    video.loadPixels();

    // first line
    int pixelIndex = ((video.width-1-x) + y*video.width);
    color c = video.pixels[pixelIndex];
    //float hueValue = hue(c);
    strokeWeight(hue(c)/50);
    stroke(c);

    diffusion = map(mouseY, 0,height, 5,100);

    beginShape();
    curveVertex(x, y);
    curveVertex(x, y);
    for (int i = 0; i < pointCount; i++) {
      int rx = (int) random(-diffusion, diffusion);
      curvePointX = constrain(x+rx, 0, width-1);
      int ry = (int) random(-diffusion, diffusion);
      curvePointY = constrain(y+ry, 0, height-1);
      curveVertex(curvePointX, curvePointY);
    }
    curveVertex(curvePointX, curvePointY);
    endShape();
    
    x = curvePointX;
    y = curvePointY;
  }
}


void keyPressed(){
  switch(key){
  case BACKSPACE:
    background(360);
    break;
  }
}


void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  
  if (key == 'r' || key == 'R'){  
    background(360);
    beginRecord(PDF, timestamp()+".pdf");
  }
  if (key == 'e' || key == 'E'){  
    endRecord();
  }

  if (key == 'q' || key == 'S') noLoop();
  if (key == 'w' || key == 'W') loop();
  
  if (keyCode == UP) pointCount = min(pointCount+1, 30);
  if (keyCode == DOWN) pointCount = max(pointCount-1, 1); 

}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}








