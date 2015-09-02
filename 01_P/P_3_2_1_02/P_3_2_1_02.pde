// P_3_2_1_02.pde
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

// CREDITS
// Geomerative library by Ricard Marxer.
// FreeSans.ttf (GNU FreeFont), see the readme files in data folder.

/**
 * fontgenerator with static elements (svg files)
 * 
 * MOUSE
 * position x          : module rotation
 * position y          : module size
 *
 * KEYS
 * a-z                 : text input (keyboard)
 * alt                 : toggle modules
 * del, backspace      : remove last letter
 * ctrl                : save png + pdf
 */

import geomerative.*;
import processing.pdf.*;
import java.util.Calendar;

boolean doSave = false;

RFont font;

String textTyped = "Type ...!";

int shapeSet = 0;
PShape module1, module2;



void setup() {
  size(1024,500);  
  // make window resizable
  surface.setResizable(true); 
  smooth();

  module1 = loadShape("A_01.svg");
  module2 = loadShape("A_02.svg");
  module1.disableStyle();
  module2.disableStyle();

  // allways initialize the library in setup
  RG.init(this);

  // load a truetype font
  font = new RFont("FreeSans.ttf", 200, RFont.LEFT);

  // ------ set style and segment resolution  ------
  //RCommand.setSegmentStep(10);
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  RCommand.setSegmentLength(6);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  //RCommand.setSegmentAngle(random(0,HALF_PI));
  //RCommand.setSegmentator(RCommand.ADAPTATIVE);
}


void draw() {
  if (doSave) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  noStroke();
  shapeMode(CENTER);

  // margin border
  translate(60, 300);

  if (textTyped.length() > 0) {
    // get the points on font outline
    RGroup grp;
    grp = font.toGroup(textTyped);
    grp = grp.toPolygonGroup();
    RPoint[] pnts = grp.getPoints();

    // ------ svg modules ------
    // module1
    fill(181, 157, 0, 200);
    float diameter = 30;
    for (int i=0; i < pnts.length-1; i++ ) {
      // on every third point
      if (i%3 == 0) {
        // rotate the module facing to the next one (i+1)
        pushMatrix();
        float angle = atan2(pnts[i].y-pnts[i+1].y, pnts[i].x-pnts[i+1].x);
        translate(pnts[i].x, pnts[i].y);
        rotate(angle);
        rotate(radians(-mouseX));
        shape(module1, 0,0, diameter+(mouseY/2.5),diameter+(mouseY/2.5));
        popMatrix();
      }
    }

    // module2
    fill(0, 130, 164, 200);
    diameter = 18;
    for (int i=0; i < pnts.length-1; i++ ) {
      // on every third point
      if (i%3 == 0) {
        // rotate the module facing to the next one (i+1)
        pushMatrix();
        float angle = atan2(pnts[i].y-pnts[i+1].y, pnts[i].x-pnts[i+1].x);
        translate(pnts[i].x, pnts[i].y);
        rotate(angle);
        rotate(radians(mouseX));
        shape(module2, 0,0, diameter+(mouseY/2.5),diameter+(mouseY/2.5));
        popMatrix();
      }
    }

    if (doSave) {
      doSave = false;
      endRecord();
      saveFrame(timestamp()+".png");
    }
  }
}


void keyReleased() {
  if (keyCode == CONTROL) doSave = true;
}


void keyPressed() {
  if (key != CODED) {
    switch(key) {
    case '1':
    case DELETE:
    case BACKSPACE:
      textTyped = textTyped.substring(0,max(0,textTyped.length()-1));
      break;
    case TAB:    
    case ENTER:
    case RETURN:
    case ESC:
      break;
    default:
      textTyped += key;
    }
  }

  if (keyCode == ALT) {
    shapeSet = (shapeSet+1) % 4;
    switch(shapeSet) {
    case 0: 
      module1 = loadShape("A_01.svg");
      module2 = loadShape("A_02.svg");
      break; 
    case 1: 
      module1 = loadShape("B_01.svg");
      module2 = loadShape("B_02.svg");
      break; 
    case 2: 
      module1 = loadShape("C_01.svg");
      module2 = loadShape("C_02.svg");
      break; 
    case 3: 
      module1 = loadShape("D_01.svg");
      module2 = loadShape("D_02.svg");
      break; 
    }
    module1.disableStyle();
    module2.disableStyle();
  }
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}