// P_2_1_2_02.pde
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
 * changing module color and positions in a grid
 * 	 
 * MOUSE
 * position x          : offset x
 * position y          : offset y
 * left click          : random position
 * 
 * KEYS
 * 1-3                 : different sets of colors
 * 0                   : default
 * arrow up/down       : background module size
 * arrow left/right    : foreground module size
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

color moduleColorBackground = color(0);
color moduleColorForeground = color(255);

color moduleAlphaBackground = 100;
color moduleAlphaForeground = 100;

float moduleRadiusBackground = 30;
float moduleRadiusForeground = 15;

color backColor = color(255);


float tileCount = 20;
int actRandomSeed = 0;

void setup(){
  size(600, 600);
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  translate(width/tileCount/2, height/tileCount/2);

  colorMode(HSB, 360, 100, 100, 100);
  background(backColor);
  smooth();
  noStroke();

  randomSeed(actRandomSeed);

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {
      float posX = width/tileCount * gridX;
      float posY = height/tileCount * gridY;

      float shiftX =  random(-1, 1) * mouseX/20;
      float shiftY =  random(-1, 1) * mouseY/20;

      fill(moduleColorBackground, moduleAlphaBackground);
      ellipse(posX+shiftX, posY+shiftY, moduleRadiusBackground, moduleRadiusBackground);
    }
  }

  for (int gridY=0; gridY<tileCount; gridY++) {
    for (int gridX=0; gridX<tileCount; gridX++) {

      float posX = width/tileCount * gridX;
      float posY = height/tileCount * gridY;

      fill(moduleColorForeground, moduleAlphaForeground);
      ellipse(posX, posY, moduleRadiusForeground, moduleRadiusForeground);
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

  if (key == '1'){
    if (moduleColorBackground == color(0)) {
      moduleColorBackground = color(273, 73, 51);
    } 
    else {
      moduleColorBackground = color(0);
    } 
  }
  if (key == '2'){
    if (moduleColorForeground == color(360)) {
      moduleColorForeground = color(323, 100, 77);
    } 
    else {
      moduleColorForeground = color(360);
    } 
  }

  if (key == '3'){
    if (moduleAlphaBackground == 100) {
      moduleAlphaBackground = 50;
      moduleAlphaForeground = 50;
    } 
    else {
      moduleAlphaBackground = 100;
      moduleAlphaForeground = 100;
    } 
  }


  if (key == '0'){  
    moduleColorBackground = color(0);
    moduleColorForeground = color(360);
    moduleAlphaBackground = 100;
    moduleAlphaForeground = 100;
    moduleRadiusBackground = 20;
    moduleRadiusForeground = 10;
  }

  if (keyCode == UP) moduleRadiusBackground += 2;
  if (keyCode == DOWN) moduleRadiusBackground = max(moduleRadiusBackground-2, 10);
  if (keyCode == LEFT) moduleRadiusForeground = max(moduleRadiusForeground-2, 5);
  if (keyCode == RIGHT) moduleRadiusForeground += 2;

}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}












