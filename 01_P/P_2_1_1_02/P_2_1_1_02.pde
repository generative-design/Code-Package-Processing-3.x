// P_2_1_1_02.pde
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
 * changing strokeweight on diagonals in a grid with colors
 * 	 
 * MOUSE
 * position x          : left diagonal strokeweight
 * position y          : right diagonal strokeweight
 * left click          : new random layout
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 * 1                   : round strokecap
 * 2                   : square strokecap
 * 3                   : project strokecap
 * 4                   : color left diagonal
 * 5                   : color right diagonal
 * 6                   : transparency left diagonal
 * 7                   : transparency right diagonal
 * 0                   : default
 */
 
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int tileCount = 20;

color colorLeft = color(197, 0, 123);
color colorRight = color(87, 35, 129);

int alphaLeft = 100;
int alphaRight = 100;

int actRandomSeed = 0;
int actStrokeCap = ROUND;


void setup() {
  size(600, 600);
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");
  
  colorMode(HSB, 360, 100, 100, 100);
  background(360);
  smooth();
  noFill();
  strokeCap(actStrokeCap);
  
  randomSeed(actRandomSeed);

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {

      int posX = width/tileCount*gridX;
      int posY = height/tileCount*gridY;

      int toggle = (int) random(0,2);

      if (toggle == 0) {
        stroke(colorLeft, alphaLeft);
        strokeWeight(mouseX/10);
        line(posX, posY, posX+width/tileCount, posY+height/tileCount);
      }
      if (toggle == 1) {
        stroke(colorRight, alphaRight);
        strokeWeight(mouseY/10);
        line(posX, posY+width/tileCount, posX+height/tileCount, posY);
      }
    }
  }
  
  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void mousePressed() {
  actRandomSeed = (int) random(100000);
}


void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  
  if (key == '1') actStrokeCap = ROUND;  
  if (key == '2') actStrokeCap = SQUARE;
  if (key == '3') actStrokeCap = PROJECT; 
  
  if (key == '4'){
    if (colorLeft == color(0)) {
      colorLeft = color(323, 100, 77);
    } else {
      colorLeft = color(0);
    } 
  }
  if (key == '5'){
    if (colorRight == color(0)) {
      colorRight = color(273, 73, 51);
    } else {
      colorRight = color(0);
    } 
  }
  
  if (key == '6') {
    if (alphaLeft == 100) {
      alphaLeft = 50;
    } else {
      alphaLeft = 100;
    }
  }
  if (key == '7') {
    if (alphaRight == 100) {
      alphaRight = 50;
    } else {
      alphaRight = 100;
    }
  }
    
  if (key == '0'){
    actStrokeCap = ROUND;
    colorLeft = color(0);
    colorRight = color(0);
    alphaLeft = 100;
    alphaRight = 100;
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}






