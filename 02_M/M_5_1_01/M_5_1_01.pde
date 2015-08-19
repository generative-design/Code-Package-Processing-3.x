// M_5_1_01.pde
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
 * simple example of a recursive function
 * 
 * KEYS
 * 1-9                 : recursion level
 * p                   : save pdf
 * s                   : save png
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int recursionLevel = 6;
float startRadius = 200;

void setup() {
  size(800,800);
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  smooth();
  noFill();
  strokeCap(PROJECT);

  translate(width/2, height/2);

  drawBranch(0, 0, startRadius, recursionLevel);

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


// ------ recursive function ------
void drawBranch(float x, float y, float radius, int level) {
  // draw arc
  strokeWeight(level*2);
  stroke(0, 130, 164, 100);
  noFill();
  arc(x,y, radius*2,radius*2, -PI,0);

  // draw center dot
  fill(0);
  noStroke();
  ellipse(x,y, level*1.5,level*1.5);

  // as long as level is greater than zero, draw sub-branches
  if (level > 0) {
    // left branch
    drawBranch(x-radius, y+radius/2, radius/2, level-1);
    // right branch
    drawBranch(x+radius, y+radius/2, radius/2, level-1);
  }
}



void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'p' || key == 'P') savePDF = true;
  
  int k = int(key)-49;
  if (k>=0 && k<9) {
    recursionLevel = k;
  }
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}








