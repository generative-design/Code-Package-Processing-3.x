// P_4_3_1_01.pde
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
 * pixel mapping. each pixel is translated into a new element
 * 
 * MOUSE
 * position x/y        : various parameters (depending on draw mode)
 * 
 * KEYS
 * 1-9                 : switch draw mode
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

PImage img;
int drawMode = 1;


void setup() {
  size(603, 873); //size should be multiple of img width and height
  smooth();
  img = loadImage("pic.png");
  println(img.width+" x "+img.height);
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  background(255);

  float mouseXFactor = map(mouseX, 0,width, 0.05,1);
  float mouseYFactor = map(mouseY, 0,height, 0.05,1);

  for (int gridX = 0; gridX < img.width; gridX++) {
    for (int gridY = 0; gridY < img.height; gridY++) {
      // grid position + tile size
      float tileWidth = width / (float)img.width;
      float tileHeight = height / (float)img.height;
      float posX = tileWidth*gridX;
      float posY = tileHeight*gridY;

      // get current color
      color c = img.pixels[gridY*img.width+gridX];
      // greyscale conversion
      int greyscale =round(red(c)*0.222+green(c)*0.707+blue(c)*0.071);

      switch(drawMode) {
      case 1:
        // greyscale to stroke weight
        float w1 = map(greyscale, 0,255, 15,0.1);
        stroke(0);
        strokeWeight(w1 * mouseXFactor);
        line(posX, posY, posX+5, posY+5); 
        break;
      case 2:
        // greyscale to ellipse area
        fill(0);
        noStroke();
        float r2 = 1.1284 * sqrt(tileWidth*tileWidth*(1-greyscale/255.0));
        r2 = r2 * mouseXFactor * 3;
        ellipse(posX, posY, r2, r2);
        break;
      case 3:
        // greyscale to line length
        float l3 = map(greyscale, 0,255, 30,0.1);
        l3 = l3 * mouseXFactor;   
        stroke(0);
        strokeWeight(10 * mouseYFactor);
        line(posX, posY, posX+l3, posY+l3);
        break;
      case 4:
        // greyscale to rotation, line length and stroke weight
        stroke(0);
        float w4 = map(greyscale, 0,255, 10,0);
        strokeWeight(w4 * mouseXFactor + 0.1);
        float l4 = map(greyscale, 0,255, 35,0);
        l4 = l4 * mouseYFactor;
        pushMatrix();
        translate(posX, posY);
        rotate(greyscale/255.0 * PI);
        line(0, 0, 0+l4, 0+l4);
        popMatrix();
        break;
      case 5:
        // greyscale to line relief
        float w5 = map(greyscale,0,255,5,0.2);
        strokeWeight(w5 * mouseYFactor + 0.1);
        // get neighbour pixel, limit it to image width
        color c2 = img.get(min(gridX+1,img.width-1), gridY);
        stroke(c2);
        int greyscale2 = int(red(c2)*0.222 + green(c2)*0.707 + blue(c2)*0.071);
        float h5 = 50 * mouseXFactor;
        float d1 = map(greyscale, 0,255, h5,0);
        float d2 = map(greyscale2, 0,255, h5,0);
        line(posX-d1, posY+d1, posX+tileWidth-d2, posY+d2);
        break;
      case 6:
        // pixel color to fill, greyscale to ellipse size
        float w6 = map(greyscale, 0,255, 25,0);
        noStroke();
        fill(c);
        ellipse(posX, posY, w6 * mouseXFactor, w6 * mouseXFactor); 
        break;
      case 7:
        stroke(c);
        float w7 = map(greyscale, 0,255, 5,0.1);
        strokeWeight(w7);
        fill(255,255* mouseXFactor);
        pushMatrix();
        translate(posX, posY);
        rotate(greyscale/255.0 * PI* mouseYFactor);
        rect(0,0,15,15);
        popMatrix();
        break;
      case 8:
        noStroke();
        fill(greyscale,greyscale * mouseXFactor,255* mouseYFactor);
        rect(posX,posY,3.5,3.5);
        rect(posX+4,posY,3.5,3.5);
        rect(posX,posY+4,3.5,3.5);
        rect(posX+4,posY+4,3.5,3.5);
        break;
      case 9:
        stroke(255,greyscale,0);
        noFill();
        pushMatrix();
        translate(posX, posY);
        rotate(greyscale/255.0 * PI);
        strokeWeight(1);
        rect(0,0,15* mouseXFactor,15* mouseYFactor);
        float w9 = map(greyscale, 0,255, 15,0.1);
        strokeWeight(w9);
        stroke(0,70);
        ellipse(0,0,10,5);
        popMatrix();
        break;
      }

    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key == '3') drawMode = 3;
  if (key == '4') drawMode = 4;
  if (key == '5') drawMode = 5;
  if (key == '6') drawMode = 6;
  if (key == '7') drawMode = 7;
  if (key == '8') drawMode = 8;
  if (key == '9') drawMode = 9;
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}





























