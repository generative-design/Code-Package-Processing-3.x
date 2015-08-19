// P_2_3_4_01.pde
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
 * 
 * MOUSE
 * drag                : draw
 * 
 * KEYS
 * 1-9                 : switch module
 * del, backspace      : clear screen
 * arrow up            : module size +
 * arrow down          : module size -
 * arrow left          : step size -
 * arrow right         : step size +
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

float x = 0, y = 0;
float stepSize = 5.0;
float moduleSize = 25;

PShape lineModule;

void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  x = mouseX;
  y = mouseY;
  cursor(CROSS);
  lineModule = loadShape("01.svg");

  /*
  // load an image in background
   PImage img = loadImage(selectInput("select a background image"));
   image(img, 0, 0, width, height);
   */
}

void draw() {
  if (mousePressed) {
    float d = dist(x,y, mouseX,mouseY);

    if (d > stepSize) {
      float angle = atan2(mouseY-y, mouseX-x); 

      pushMatrix();
      translate(mouseX, mouseY);
      rotate(angle+PI);
      shape(lineModule, 0, 0, d, moduleSize);
      popMatrix();

      x = x + cos(angle) * stepSize;
      y = y + sin(angle) * stepSize;
    }
  }
}

void mousePressed() {
  x = mouseX;
  y = mouseY;
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == DELETE || key == BACKSPACE) background(255);

  // load svg for line module
  if (key=='1') lineModule = loadShape("01.svg");
  if (key=='2') lineModule = loadShape("02.svg");
  if (key=='3') lineModule = loadShape("03.svg");
  if (key=='4') lineModule = loadShape("04.svg");
  if (key=='5') lineModule = loadShape("05.svg");
  if (key=='6') lineModule = loadShape("06.svg");
  if (key=='7') lineModule = loadShape("07.svg");
  if (key=='8') lineModule = loadShape("08.svg");
  if (key=='9') lineModule = loadShape("09.svg");

  // ------ pdf export ------
  // press 'r' to start pdf recordPDF and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+"_.pdf");
      println("recording started");
      recordPDF = true;
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(255); 
    }
  } 
}

void keyPressed() {
  if(key == CODED) {
    // moduleSize ctrls arrowkeys up/down 
    if (keyCode == UP) moduleSize += 5;
    if (keyCode == DOWN) moduleSize -= 5; 
    // stepSize ctrls arrowkeys left/right
    stepSize = max(stepSize,0.5);   
    if (keyCode == LEFT) stepSize -= 0.5;
    if (keyCode == RIGHT) stepSize += 0.5; 
    println("moduleSize: "+moduleSize+"  stepSize: "+stepSize);
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}











