// M_1_5_01.pde
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
 * how to transform noise values into directions (angles) and brightness levels
 * 
 * MOUSE
 * position x/y        : specify noise input range
 * 
 * KEYS
 * d                   : toogle display brightness circles on/off
 * arrow up            : noise falloff +
 * arrow down          : noise falloff -
 * arrow left          : noise octaves -
 * arrow right         : noise octaves +
 * space               : new noise seed
 * s                   : save png
 * p                   : save pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int octaves = 4;
float falloff = 0.5;

color arcColor = color(0,130,164,100);

float tileSize = 40;
int gridResolutionX, gridResolutionY;
boolean debugMode = true;
PShape arrow;

void setup() {
  size(800,800); 
  cursor(CROSS);
  gridResolutionX = round(width/tileSize);
  gridResolutionY = round(height/tileSize);
  smooth();
  arrow = loadShape("arrow.svg");
}

void draw() {
  background(255);
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  noiseDetail(octaves,falloff);
  float noiseXRange = mouseX/100.0;
  float noiseYRange = mouseY/100.0;

  for (int gY=0; gY<= gridResolutionY; gY++) {  
    for (int gX=0; gX<= gridResolutionX; gX++) {
      float posX = tileSize*gX;
      float posY = tileSize*gY;

      // get noise value
      float noiseX = map(gX, 0,gridResolutionX, 0,noiseXRange);
      float noiseY = map(gY, 0,gridResolutionY, 0,noiseYRange);
      float noiseValue = noise(noiseX,noiseY);
      float angle = noiseValue*TWO_PI;

      pushMatrix();
      translate(posX,posY);

      // debug heatmap
      if (debugMode) {
        noStroke();
        ellipseMode(CENTER);
        fill(noiseValue*255);
        ellipse(0,0,tileSize*0.25,tileSize*0.25);
      }

      // arc
      noFill();
      strokeCap(SQUARE);
      strokeWeight(1);
      stroke(arcColor);
      arc(0,0,tileSize*0.75,tileSize*0.75,0,angle);

      // arrow
      stroke(0);
      strokeWeight(0.75);
      rotate(angle);
      shape(arrow,0,0,tileSize*0.75,tileSize*0.75);
      popMatrix();
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
  println("octaves: "+octaves+" falloff: "+falloff+" noiseXRange: 0-"+noiseXRange+" noiseYRange: 0-"+noiseYRange); 
}

void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'p' || key == 'P') savePDF = true;
  if (key == 'd' || key == 'D') debugMode = !debugMode;
  if (key == ' ') noiseSeed((int) random(100000));
}

void keyPressed() {
  if (keyCode == UP) falloff += 0.05;
  if (keyCode == DOWN) falloff -= 0.05;
  if (falloff > 1.0) falloff = 1.0;
  if (falloff < 0.0) falloff = 0.0;

  if (keyCode == LEFT) octaves--;
  if (keyCode == RIGHT) octaves++;
  if (octaves < 0) octaves = 0;
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}



