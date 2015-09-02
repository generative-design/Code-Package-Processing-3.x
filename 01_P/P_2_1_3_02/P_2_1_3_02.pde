// P_2_1_3_02.pde
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
 * draw a module made of lines in a grid
 * 	 
 * MOUSE
 * position x          : number of tiles horizontally
 * position y          : number of tiles vertically
 * 
 * KEYS
 * 1-3                 : draw mode
 * s                   : save png
 * p                   : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

float tileCountX = 5;
float tileCountY = 5;

int count = 10;
int colorStep = 20;

int lineWeight = 0;
int strokeColor = 0;

color backgroundColor = 0;

int drawMode = 1;

void setup() { 
  size(600, 600);
} 

void draw() { 
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  colorMode(HSB, 360, 100, 100); 
  strokeWeight(0.5);
  strokeCap(ROUND);

  tileCountX = mouseX/30+1;
  tileCountY = mouseY/30+1;

  background(backgroundColor);

  for (int gridY=0; gridY<= tileCountY; gridY++) {
    for (int gridX=0; gridX<= tileCountX; gridX++) {  

      float tileWidth = width/tileCountX;
      float tileHeight = height/tileCountY;
      float posX = tileWidth*gridX;
      float posY = tileHeight*gridY;

      float x1 = tileWidth/2;
      float y1 = tileHeight/2;
      float x2 = 0;
      float y2 = 0;

      pushMatrix();
      translate(posX, posY);

      for(int side = 0; side < 4; side++) {
        for(int i=0; i< count; i++) {

           // move end point around the four sides of the tile
          if(side == 0){     
            x2 += tileWidth/count;
            y2 = 0;
          }
          if(side == 1){     
            x2 = tileWidth;
            y2 += tileHeight/count;
          }
          if(side == 2){     
            x2 -= tileWidth/count;
            y2 = tileHeight;
          }
          if(side == 3){     
            x2 = 0;
            y2 -= tileHeight/count;
          }

          // adjust weight and color of the line
          if(i < count/2){
            lineWeight += 1;
            strokeColor += 60;
          } 
          else {
            lineWeight -= 1;
            strokeColor -= 60;
          }

          // set colors depending on draw mode
          switch(drawMode){
          case 1:
            backgroundColor = 360;
            stroke(0);
            break;
          case 2:
            backgroundColor = 360;
            stroke(0);
            strokeWeight(lineWeight);
            break;
          case 3:
            backgroundColor = 0;
            stroke(strokeColor);
            strokeWeight(mouseX/100);
            break;
          }

          // draw the line
          line(x1, y1, x2, y2);
        }
      }

      popMatrix();
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
} 


void keyPressed() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;

  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key == '3') drawMode = 3;
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}