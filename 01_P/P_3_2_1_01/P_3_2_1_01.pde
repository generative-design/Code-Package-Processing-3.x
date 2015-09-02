// P_3_2_1_01.pde
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
 * typo outline displayed as dots and lines
 *     
 * KEYS
 * a-z                  : text input (keyboard)
 * backspace            : delete last typed letter
 * ctrl                 : save png + pdf
 */

import processing.pdf.*;
import geomerative.*;
import java.util.Calendar;

RFont font;
String textTyped = "Type ...!";

boolean doSave = false;


void setup() {
  size(1324,350);  
  // make window resizable
  surface.setResizable(true); 
  smooth();

  // allways initialize the library in setup
  RG.init(this);
  font = new RFont("FreeSans.ttf", 200, RFont.LEFT);

  // get the points on the curve's shape
  // set style and segment resultion

  //RCommand.setSegmentStep(11);
  //RCommand.setSegmentator(RCommand.UNIFORMSTEP);

  RCommand.setSegmentLength (11);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  //RCommand.setSegmentAngle(random(0,HALF_PI));
  //RCommand.setSegmentator(RCommand.ADAPTATIVE);
}


void draw() {
  if (doSave) beginRecord(PDF, timestamp()+"_####.pdf");

  background(255);
  // margin border
  translate(20,220);

  if (textTyped.length() > 0) {
    // get the points on font outline
    RGroup grp;
    grp = font.toGroup(textTyped);
    grp = grp.toPolygonGroup();
    RPoint[] pnts = grp.getPoints();

    // lines
    stroke(181, 157, 0);
    strokeWeight(1.0);
    for (int i = 0; i < pnts.length; i++ ) {
      float l = 5;
      line(pnts[i].x-l, pnts[i].y-l, pnts[i].x+l, pnts[i].y+l);
    }

    // dots
    fill(0);
    noStroke();
    for (int i = 0; i < pnts.length; i++ ) {
      float diameter = 7;
      // on ervery second point
      if (i%2 == 0) {
        ellipse(pnts[i].x, pnts[i].y, diameter, diameter);
      }
    }

    if (doSave) {
      doSave = false;
      endRecord();
      saveFrame(timestamp()+"_####.png");
    }
  }
}


void keyPressed() {
  // println(keyCode+" -> "+key);
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

  if (keyCode == CONTROL) doSave = true;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}