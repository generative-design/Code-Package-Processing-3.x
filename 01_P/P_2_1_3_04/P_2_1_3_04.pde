// P_2_1_3_04.pde
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
 * changing positions of stapled circles in a grid
 * 	 
 * MOUSE
 * position x          : module detail
 * position y          : module parameter
 * 
 * KEYS
 * 1-3                 : draw mode
 * arrow left/right    : number of tiles horizontally
 * arrow up/down       : number of tiles vertically
 * s                   : save png
 * p                   : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

float tileCountX = 6;
float tileCountY = 6;
int count = 0;

int drawMode = 1;


void setup() { 
  size(550, 550);
} 


void draw() { 
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  colorMode(HSB, 360, 100, 100); 
  rectMode(CENTER);
  smooth();
  stroke(0);
  noFill();
  background(360); 
  
  count = mouseX/10 + 10;
  float para = (float)mouseY/height;

  for (int gridY=0; gridY<= tileCountY; gridY++) {
    for (int gridX=0; gridX<= tileCountX; gridX++) {  

      float tileWidth = width / tileCountX;
      float tileHeight = height / tileCountY;
      float posX = tileWidth*gridX + tileWidth/2;
      float posY = tileHeight*gridY + tileHeight/2;

      pushMatrix();
      translate(posX, posY);

      // switch between modules
      switch (drawMode) {
      case 1:
        for(int i=0; i < count; i++) {
          rect(0, 0, tileWidth, tileHeight);
          scale(1 - 3.0/count);
          rotate(para*0.1);
        }
        break;

      case 2:
        for(float i=0; i< count; i++) {
          noStroke();
          color gradient = lerpColor(color(0), color(52, 100, 71), i/count);
          fill(gradient, i/count*200);
          rotate(PI/4);
          rect(0, 0, tileWidth, tileHeight);
          scale(1 - 3.0/count);
          rotate(para*1.5);
        }
        break;

      case 3:
        colorMode(RGB, 255);
        for(float i=0; i< count; i++) {
          noStroke();
          color gradient = lerpColor(color(0, 130, 164), color(255), i/count);
          fill(gradient,170);

          pushMatrix();
          translate(4*i,0);
          ellipse(0, 0, tileWidth/4, tileHeight/4);
          popMatrix();

          pushMatrix();
          translate(-4*i,0);
          ellipse(0, 0, tileWidth/4, tileHeight/4);
          popMatrix();

          scale(1 - 1.5/count);
          rotate(para*1.5);
        }

        break;
      }

      popMatrix();

    }
  }
  if (savePDF) {
    savePDF = false;
    endRecord();
  }
} 


void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key == '3') drawMode = 3;

  if (keyCode == DOWN) tileCountY = max(tileCountY-1, 1);
  if (keyCode == UP) tileCountY += 1;
  if (keyCode == LEFT) tileCountX = max(tileCountX-1, 1);
  if (keyCode == RIGHT) tileCountX += 1;

}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}











