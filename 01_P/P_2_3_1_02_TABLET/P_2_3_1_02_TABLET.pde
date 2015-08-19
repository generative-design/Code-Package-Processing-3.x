// P_2_3_1_02_TABLET.pde
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
 * draw tool. draw with a rotating element. 
 * 
 * MOUSE
 * drag                : draw
 * 
 * TABLET
 * pressure            : module width
 * 
 * KEYS
 * 1-4                 : switch brush color
 * 5-9                 : switch brush element
 * del, backspace      : clear screen
 * d                   : reverse direction and mirrow angle 
 * p                   : toggle pressure on/off
 * space               : new random color
 * arrow left          : rotaion speed -
 * arrow right         : rotaion speed +
 * shift               : limit drawing direction
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;

Tablet tablet;

boolean recording = false;

color col = color(181,157,0,100);
float lineModuleSize = 200;
float angle = 0;
float angleSpeed = 1.0;
PShape lineModule = null;
boolean pressureOn = false;
float pressure = 1;

int clickPosX = 0;
int clickPosY = 0;




void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  cursor(CROSS);

  tablet = new Tablet(this); 
}

void draw() {
  // gamma values optimized for wacom intuos 3
  if (pressureOn == true) {
    pressure = gamma(tablet.getPressure()*1.1, 2.5);
  }
  else {
    pressure = 1; 
  }

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
    // gamma values optimized for wacom intuos 3
    float lineModuleSizeNow = 5 + lineModuleSize * pressure;

    if (lineModule != null) {
      shape(lineModule, 0, 0, lineModuleSizeNow, lineModuleSizeNow);
    } 
    else {
      line(0, 0, lineModuleSizeNow, lineModuleSizeNow);
    }

    //angleSpeed = map(tablet.getPressure(),0,1,0.5,10);
    angle = angle + angleSpeed;
    popMatrix();
  }
}


void mousePressed() {
  // create a new random color and line length
  if (!pressureOn) {
    lineModuleSize = random(50,160);
  }

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
  if (key == ' ') col = color(random(255),random(255),random(255),random(150,220));

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

  if (key=='p') pressureOn = !pressureOn;


  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recording == false) {
      beginRecord(PDF, timestamp()+"_.pdf");
      println("recording started");
      recording = true;
    }
  } 
  else if (key == 'e' || key =='E') {
    if (recording) {
      println("recording stopped");
      endRecord();
      recording = false;
      background(255); 
    }
  } 
}

void keyPressed() {
  if (keyCode == LEFT) angleSpeed -= 0.5;
  if (keyCode == RIGHT) angleSpeed += 0.5; 
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



























