// P_4_1_1_01.pde
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
 * cutting and multiplying an area of the image
 * 
 * MOUSE
 * position x/y         : area position
 * left click           : multiply the area
 * 
 * KEYS
 * 1-3                  : area size
 * r                    : toggle random area
 * s                    : save png
 */

import java.util.Calendar;

PImage img;

int tileCountX = 4;
int tileCountY = 4;
int tileCount = tileCountX*tileCountY;
PImage[] imageTiles = new PImage[tileCount];

int tileWidth, tileHeight;

int cropX = 0;
int cropY = 0;

boolean selectMode = true;
boolean randomMode = false; 


void setup() {
  size(1600, 1200); 
  img = loadImage("image.jpg");
  image(img, 0, 0);
  noCursor();

  tileWidth = width/tileCountY;
  tileHeight = height/tileCountX;
}


void draw() {
  if (selectMode == true) {
    // in selection mode, a white selection rectangle is drawn over the image
    cropX = constrain(mouseX, 0, width-tileWidth);
    cropY = constrain(mouseY, 0, height-tileHeight);    
    image(img, 0, 0);
    noFill();
    stroke(255);
    rect(cropX, cropY, tileWidth, tileHeight);
  } 
  else {
    // reassemble image
    int i = 0;
    for (int gridY = 0; gridY < tileCountY; gridY++){
      for (int gridX = 0; gridX < tileCountX; gridX++){
        image(imageTiles[i], gridX*tileWidth, gridY*tileHeight);
        i++;
      }
    }

  }

}

void cropTiles() {
  tileWidth = width/tileCountY;
  tileHeight = height/tileCountX;
  tileCount = tileCountX * tileCountY;
  imageTiles = new PImage[tileCount];

  int i = 0;
  for (int gridY = 0; gridY < tileCountY; gridY++){
    for (int gridX = 0; gridX < tileCountX; gridX++){
      if (randomMode){
        cropX = (int) random(mouseX-tileWidth/2, mouseX+tileWidth/2);
        cropY = (int) random(mouseY-tileHeight/2, mouseY+tileHeight/2);
      }
      cropX = constrain(cropX, 0, width-tileWidth);
      cropY = constrain(cropY, 0, height-tileHeight);
      imageTiles[i++] = img.get(cropX, cropY, tileWidth, tileHeight);
    }
  }
}


void mouseMoved() {
  selectMode = true;
}

void mouseReleased(){
  selectMode = false; 
  cropTiles();
}



void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");

  if (key == 'r' || key == 'R') {
    randomMode = !randomMode;
    cropTiles();
  }

  if (key == '1'){
    tileCountY = 4;
    tileCountX = 4;
    cropTiles();
  }
  if (key == '2'){
    tileCountY = 10;
    tileCountX = 10;
    cropTiles();
  }
  if (key == '3'){
    tileCountY = 20;
    tileCountX = 20;
    cropTiles();
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
























