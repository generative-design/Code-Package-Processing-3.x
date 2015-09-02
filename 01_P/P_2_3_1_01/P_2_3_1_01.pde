// P_2_3_1_01.pde
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
 * draw tool. draw with a rotating line. 
 * 
 * MOUSE
 * drag                : draw
 * 
 * KEYS
 * 1-4                 : switch default colors
 * del, backspace      : clear screen
 * d                   : reverse direction and mirrow angle 
 * space               : new random color
 * arrow left          : rotaion speed -
 * arrow right         : rotaion speed +
 * arrow up            : line length +
 * arrow down          : line length -
 * s                   : save png
 * r                   : start pdf recording
 * e                   : stop pdf recording
 */

import processing.pdf.*;
import java.util.Calendar;

boolean recordPDF = false;

color col = color(181, 157, 0, 100);
float lineLength = 0;
float angle = 0;
float angleSpeed = 1.0;

void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  cursor(CROSS);
}

void draw() {
  if (mousePressed) {
    pushMatrix();
    strokeWeight(1.0); 
    noFill();
    stroke(col);
    translate(mouseX, mouseY);
    rotate(radians(angle));
    line(0, 0, lineLength, 0);
    popMatrix();

    angle += angleSpeed;
  }
}

void mousePressed() {
  // create a new random line length
  lineLength = random(70, 200);
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
  if (key == ' ') col = color(random(255), random(255), random(255), random(80, 150));

  //default colors from 1 to 4 
  if (key == '1') col = color(181, 157, 0, 100);
  if (key == '2') col = color(0, 130, 164, 100);
  if (key == '3') col = color(87, 35, 129, 100);
  if (key == '4') col = color(197, 0, 123, 100);

  // ------ pdf export ------
  // press 'r' to start pdf recording and 'e' to stop it
  // ONLY by pressing 'e' the pdf is saved to disk!
  if (key =='r' || key =='R') {
    if (recordPDF == false) {
      beginRecord(PDF, timestamp()+".pdf");
      println("recording started");
      recordPDF = true;
    }
  } else if (key == 'e' || key =='E') {
    if (recordPDF) {
      println("recording stopped");
      endRecord();
      recordPDF = false;
      background(255);
    }
  }
}

void keyPressed() {
  if (keyCode == UP) lineLength += 5;
  if (keyCode == DOWN) lineLength -= 5; 
  if (keyCode == LEFT) angleSpeed -= 0.5;
  if (keyCode == RIGHT) angleSpeed += 0.5;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}