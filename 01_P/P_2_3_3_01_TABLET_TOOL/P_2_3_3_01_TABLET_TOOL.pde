// P_2_3_3_01_TABLET_TOOL.pde
// drawItem.pde
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
 * this sketch does more less the same like P_2_3_3_01_TABLET.pde ...
 * but it shows how to implement an undo feature. not really for beginners. 
 *
 * MOUSE
 * drag                : draw with text
 *
 * TABLET
 * pressure            : textsize
 * 
 * KEYS
 * del, backspace      : clear screen
 * shift               : limit drawing direction
 * z                   : undo last action
 * u                   : show underlay picture
 * arrow up            : angle distortion +
 * arrow down          : angle distortion -
 * s                   : save png
 * p                   : save pdf
 */

import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;

Tablet tablet;

boolean savePDF = false;

float x = 0, y = 0;
float stepSize = 5.0;

PFont font;
String letters = "Sie hören nicht die folgenden Gesänge, Die Seelen, denen ich die ersten sang, Zerstoben ist das freundliche Gedränge, Verklungen ach! der erste Wiederklang.";
int fontSizeMin = 5;
float angleDistortion = 0.0;

int counter = 0;

ArrayList drawItems;
int undoIndex = 0;

boolean showUndelay = false;
PImage img;
int imageAlpha = 100;

//int clickPosX = 0;
//int clickPosY = 0;


void setup() {
  // use fullscreen size 
  size(displayWidth, displayHeight);
  background(255);
  smooth();
  tablet = new Tablet(this); 
  drawItems = new ArrayList();

  //println(PFont.list()); 
  //font = createFont("Arial",10);
  font = createFont("ArnhemFineTT-Normal",10);
  textFont(font,fontSizeMin);
  cursor(CROSS);

  // load an image in background
  img = loadImage("underlay.png");
}

void draw() {
  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
    reDrawAllDrawItems();
  }
  if (savePDF) {
    savePDF = false;
    endRecord();
  }

  if (mousePressed) {
    // gamma values optimized for wacom intuos 3
    float pressure = gamma(tablet.getPressure()*1.1, 2.5);

    float d = dist(x,y, mouseX,mouseY);
    float newFontSize = fontSizeMin + 200*pressure;
    textFont(font, newFontSize);
    char newLetter = letters.charAt(counter);
    stepSize = textWidth(newLetter);

    float angle = atan2(mouseY-y, mouseX-x); 
    if (keyPressed && keyCode == SHIFT) {
      angle = round(8*angle/TWO_PI);
      if (angle%2 == 0) angle = angle * TWO_PI / 8;
      else d = 0;
    }

    if (d > stepSize) {
      angle += random(angleDistortion);

      drawItem drw = new drawItem();
      drw.angle = angle;
      drw.x = x;
      drw.y = y; 
      drw.letter = newLetter;
      drw.fontSize = newFontSize;

      drw.draw();
      drawItems.add(drw);

      counter++;
      if (counter > letters.length()-1) counter = 0;

      x = x + cos(angle) * stepSize;
      y = y + sin(angle) * stepSize; 
    }
  }
}


void mousePressed() {
  undoIndex = drawItems.size();
  x = mouseX;
  y = mouseY;

  // remember click position
  //clickPosX = mouseX;
  //clickPosY = mouseY;
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  if (key == DELETE || key == BACKSPACE) {
    background(255);
    drawItems = new ArrayList();
    undoIndex = 0;
  }
  if (key == 'u' || key == 'U') showUndelay = !showUndelay; 

  if (showUndelay) {
    background(255);
    reDrawAllDrawItems();
    tint(255, imageAlpha);
    image(img, 0, 0);
  } 
  else {
    reDrawAllDrawItems();
  }

  if (key == 'z' || key == 'Z') {
    undoDrawItems(undoIndex);
    reDrawAllDrawItems();
  }
}

void keyPressed() {
  // angleDistortion ctrls arrowkeys up/down 
  if (keyCode == UP) angleDistortion += 0.1;
  if (keyCode == DOWN) angleDistortion -= 0.1; 
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

void reDrawAllDrawItems() {
  background(255);
  for (int i = 0; i < drawItems.size(); i++) { 
    drawItem tmp = (drawItem) drawItems.get(i);
    tmp.draw();
  } 
}

void undoDrawItems(int theUndoIndex) {
  theUndoIndex -= 1; 
  if (drawItems.size() > 0 && theUndoIndex >= 0) {
    for (int i = drawItems.size()-1; i > theUndoIndex; i--) {
      drawItems.remove(i);
    }
  }
}













































