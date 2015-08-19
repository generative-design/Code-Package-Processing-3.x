// P_2_3_1_02.pde
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
 * draw tool. draw with a rotating element (svg file). 
 * 
 * MOUSE
 * drag                : draw
 * 
 * KEYS
 * 1-4                 : switch default colors
 * 5-9                 : switch brush element
 * del, backspace      : clear screen
 * d                   : reverse direction and mirrow angle 
 * space               : new random color
 * arrow left          : rotaion speed -
 * arrow right         : rotaion speed +
 * arrow up            : module size +
 * arrow down          : module size -
 * shift               : limit drawing direction
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

color col = color(181,157,0,100);
float lineModuleSize = 0;
float angle = 0;
float angleSpeed = 1.0;
PShape lineModule = null;

int clickPosX = 0;
int clickPosY = 0;


void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  cursor(CROSS);
}

void draw() {
  if (mousePressed) {
    int x = mouseX;
    int y = mouseY;
    if (keyPressed && keyCode == SHIFT) {
      if (abs(clickPosX-x) > abs(clickPosY-y)) y = clickPosY; 
      else x = clickPosX;
    }

    strokeWeight(0.75); 
    noFill();
    stroke(col);
    pushMatrix();
    translate(x, y);
    rotate(radians(angle));
    if (lineModule != null) {
      shape(lineModule, 0, 0, lineModuleSize, lineModuleSize);
    } 
    else {
      line(0, 0, lineModuleSize, lineModuleSize);
    }
    angle = angle + angleSpeed;
    popMatrix();
  }
}


void mousePressed() {
  // create a new random color and line length
  lineModuleSize = random(50,160);

  // remember click position
  clickPosX = mouseX;
  clickPosY = mouseY;
}

void keyReleased() {
  if (key == DELETE || key == BACKSPACE) background(255);
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");

  // reverse direction and mirrow angle
  if (key=='d' || key=='D') {
    angle = angle + 180;
    angleSpeed = angleSpeed * -1;
  }

  // r g b alpha
  if (key == ' ') col = color(random(255),random(255),random(255),random(80,150));

  //default colors from 1 to 4 
  if (key == '1') col = color(181,157,0,100);
  if (key == '2') col = color(0,130,164,100);
  if (key == '3') col = color(87,35,129,100);
  if (key == '4') col = color(197,0,123,100);

  // load svg for line module
  if (key=='5') lineModule = null;
  if (key=='6') lineModule = loadShape("02.svg");
  if (key=='7') lineModule = loadShape("03.svg");
  if (key=='8') lineModule = loadShape("04.svg");
  if (key=='9') lineModule = loadShape("05.svg");
  if (lineModule != null) {
    lineModule.disableStyle();
  }

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
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
      background(255); 
    }
  }  
}


void keyPressed() {
  if (keyCode == UP) lineModuleSize += 5;
  if (keyCode == DOWN) lineModuleSize -= 5; 
  if (keyCode == LEFT) angleSpeed -= 0.5;
  if (keyCode == RIGHT) angleSpeed += 0.5; 
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}




















