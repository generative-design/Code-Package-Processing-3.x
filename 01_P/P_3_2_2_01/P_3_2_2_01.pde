// P_3_2_2_01.pde
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
 * fontgenerator with dynamic elements
 * 
 * MOUSE
 * position x          : curve rotation
 * position y          : curve height
 * 
 * KEYS
 * a-z                 : text input (keyboard)
 * del, backspace      : remove last letter
 * alt                 : toggle fill style
 * ctrl                : save png + pdf
 */

import geomerative.*;
import processing.pdf.*;
import java.util.Calendar;

boolean doSave = false;

RFont font;
//String textTyped = "HELLO";

//String textTyped = "When you’re creating";
//String textTyped = "your own shit, man,";
//String textTyped = "even the sky ain’t";
//String textTyped = "  the limit.";
String textTyped = "Charles Mingus";

//String textTyped = "WHEN YOU’RE CREATING";
//String textTyped = "your own shit, man,";
//String textTyped = "even the sky ain’t";
//String textTyped = "the limit.";
  

boolean filled = false;

void setup() {
  size(1824,400);  
  // make window resizable
  surface.setResizable(true); 
  smooth();

  // allways initialize the library in setup
  RG.init(this);

  // load a truetype font
  font = new RFont("FreeSans.ttf", 200, RFont.LEFT);

  // ------ set style and segment resolution  ------
  //RCommand.setSegmentStep(10);
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  //RCommand.setSegmentAngle(random(0,HALF_PI));
  //RCommand.setSegmentator(RCommand.ADAPTATIVE);
}

void draw() {
  if (doSave) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  if (filled) {
    noStroke();
    fill(0);
  }
  else {
    noFill();
    stroke(0);
    strokeWeight(2);
  }

  // initial position
  translate(20, 260);

  if (textTyped.length() > 0) {
    // get the points on font outline
    RGroup grp;
    grp = font.toGroup(textTyped);
    grp = grp.toPolygonGroup();
    RPoint[] pnts = grp.getPoints();

    // map mouse axis
    float addToAngle = map(mouseX, 0,width, -PI,+PI);
    float curveHeight = map(mouseY, 0,height, 0.1,2);

    for (int i = 0; i < pnts.length-1; i++ ) {
      float d = dist(pnts[i].x, pnts[i].y, pnts[i+1].x, pnts[i+1].y);
      // create a gap between each letter
      if (d > 20) continue;
      // alternate in every step from -1 to 1
      float stepper = map(i%2,0,1,-1,1);
      float angle = atan2(pnts[i+1].y-pnts[i].y, pnts[i+1].x-pnts[i].x);
      angle = angle + addToAngle;

      float cx = pnts[i].x + cos(angle*stepper) * d*4 * curveHeight;
      float cy = pnts[i].y + sin(angle*stepper) * d*3 * curveHeight;

      bezier(pnts[i].x,pnts[i].y,  cx,cy, cx,cy,  pnts[i+1].x,pnts[i+1].y);
    }

  }

  if (doSave) {
    doSave = false;
    endRecord();
    saveFrame(timestamp()+".png");
  }
}

void keyReleased() {
  if (keyCode == CONTROL) doSave = true;
  if (keyCode == ALT) filled = !filled;
}

void keyPressed() {
  if (key != CODED) {
    switch(key) {
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
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}