// P_2_3_6_02.pde
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
 * draw tool. draws a specific module according to 
 * its east, south, west and north neighbours.
 * with switchable tileset 
 * 
 * MOUSE
 * drag left           : draw new module
 * drag right          : delete a module
 * 
 * KEYS
 * 1-8                 : switch tileset
 * y,x,c,v,b           : switch colors
 * del, backspace      : clear screen
 * r                   : random tiles
 * s                   : save png
 * p                   : save pdf
 * g                   : toogle. show grid
 * d                   : toogle. show module values
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

float tileSize = 30;
int gridResolutionX, gridResolutionY;
boolean drawGrid = true;
char[][] tiles;

color[][] tileColors;
color activeTileColor;

boolean randomMode = false;

PShape[] modulesA;
PShape[] modulesB;
PShape[] modulesC;
PShape[] modulesD;
PShape[] modulesE;
PShape[] modulesF;
PShape[] modulesG;
PShape[] modulesH;

char[] modules  = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
char activeModulsSet = 'A';

PFont font;
boolean debugMode = false;


void setup() {
  // use full screen size 
  size(displayWidth, displayHeight);
  //size(600,600);
  smooth();
  colorMode(HSB,360,100,100);
  cursor(CROSS);
  font = createFont("sans-serif",8);
  textFont(font,8);
  textAlign(CENTER,CENTER);

  gridResolutionX = round(width/tileSize)+2;
  gridResolutionY = round(height/tileSize)+2;
  tiles = new char[gridResolutionX][gridResolutionY];
  tileColors = new color[gridResolutionX][gridResolutionY];
  initTiles();


  // load svg modules
  modulesA = new PShape[16];
  modulesB = new PShape[16];
  modulesD = new PShape[16]; 
  modulesC = new PShape[16]; 
  modulesE = new PShape[16];  
  modulesF = new PShape[16];  
  modulesG = new PShape[16];  
  modulesH = new PShape[16];  

  for (int i=0; i< modulesA.length; i++) { 
    modulesA[i] = loadShape("A_"+nf(i,2)+".svg");
    modulesB[i] = loadShape("B_"+nf(i,2)+".svg");
    modulesC[i] = loadShape("C_"+nf(i,2)+".svg");
    modulesD[i] = loadShape("D_"+nf(i,2)+".svg");
    modulesE[i] = loadShape("E_"+nf(i,2)+".svg");
    modulesF[i] = loadShape("F_"+nf(i,2)+".svg");
    modulesG[i] = loadShape("J_"+nf(i,2)+".svg");
    modulesH[i] = loadShape("K_"+nf(i,2)+".svg");

      //disable Style
    modulesA[i].disableStyle();
    modulesB[i].disableStyle();
    modulesC[i].disableStyle();
    modulesD[i].disableStyle();
    modulesE[i].disableStyle();
    modulesF[i].disableStyle();
    modulesG[i].disableStyle();
    modulesH[i].disableStyle();

  }
}

void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  smooth();
  colorMode(HSB, 360, 100, 100, 100);
  textFont(font,8);
  textAlign(CENTER,CENTER);
  
  background(360);
  
  if (mousePressed && (mouseButton == LEFT)) setTile();
  if (mousePressed && (mouseButton == RIGHT)) unsetTile();

  if (drawGrid) drawGrid();
  drawModuls();

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}



void initTiles() {
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      tiles[gridX][gridY] = '0';
      tileColors[gridX][gridY] = color(random(255),0,random(255));
    }
  }
}

void setTile() {
  // convert mouse position to grid coordinates
  int gridX = floor((float)mouseX/tileSize) + 1;
  gridX = constrain(gridX, 1, gridResolutionX-2);
  int gridY = floor((float)mouseY/tileSize) + 1;
  gridY = constrain(gridY, 1, gridResolutionY-2);
  tiles[gridX][gridY] = activeModulsSet;
  tileColors[gridX][gridY] = activeTileColor;
}

void unsetTile() {
  int gridX = floor((float)mouseX/tileSize) + 1;
  gridX = constrain(gridX, 1, gridResolutionX-2);
  int gridY = floor((float)mouseY/tileSize) + 1;
  gridY = constrain(gridY, 1, gridResolutionY-2);
  tiles[gridX][gridY] = '0';
}


void drawGrid() {
  rectMode(CENTER);
  for (int gridY=0; gridY< gridResolutionY; gridY++) {
    for (int gridX=0; gridX< gridResolutionX; gridX++) {  
      float posX = tileSize*gridX - tileSize/2;
      float posY = tileSize*gridY - tileSize/2;
      strokeWeight(0.15);
      fill(360);
      if (debugMode) {
        if (tiles[gridX][gridY] == '1') fill(220);
      }
     stroke(0);
     noFill();
     rect(posX, posY, tileSize, tileSize);
    }
  }
}


void drawModuls() {
  if(randomMode)activeModulsSet = modules[int(random(modules.length))];
  shapeMode(CENTER);
  for (int gridY=1; gridY< gridResolutionY-1; gridY++) {  
    for (int gridX=1; gridX< gridResolutionX-1; gridX++) { 
      // use only active tiles
      char currentTile = tiles[gridX][gridY];
      if (currentTile != '0') {
        String binaryResult = "";
        // check the four neighbours. is it active (not '0')? 
        // create a binary result out of it, eg. 1011
        // binaryResult = north + west + south + east;
        // north
        if (tiles[gridX][gridY-1] != '0') binaryResult = "1";
        else binaryResult = "0";
        // west
        if (tiles[gridX-1][gridY] != '0') binaryResult += "1";
        else binaryResult += "0";  
        // south
        if (tiles[gridX][gridY+1] != '0') binaryResult += "1";
        else binaryResult += "0";
        // east
        if (tiles[gridX+1][gridY] != '0') binaryResult += "1";
        else binaryResult += "0";

        // convert the binary string to a decimal value from 0-15
        int decimalResult = unbinary(binaryResult);
        float posX = tileSize*gridX - tileSize/2;
        float posY = tileSize*gridY - tileSize/2;
      
        fill(tileColors[gridX][gridY]);
        noStroke();
        
      
        // decimalResult is the also the index for the shape array
        switch(currentTile) {
        case 'A': 
          shape(modulesA[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'B': 
          shape(modulesB[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'C': 
          shape(modulesC[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'D': 
          shape(modulesD[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'E': 
          shape(modulesE[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'F': 
          shape(modulesF[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'G': 
          shape(modulesG[decimalResult],posX, posY, tileSize, tileSize);
          break;
        case 'H': 
          shape(modulesH[decimalResult],posX, posY, tileSize, tileSize);
          break;
        }

        if (debugMode) {
          fill(150);
          text(currentTile+"\n"+decimalResult+"\n"+binaryResult,posX, posY);
        }
      }
    }
  }
}


void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  if (key == DELETE || key == BACKSPACE) initTiles();
  if (key == 'g' || key == 'G') drawGrid = !drawGrid;
  if (key == 'd' || key == 'D') debugMode = !debugMode;
  if (key == 'r' || key == 'R') randomMode = !randomMode;
  if (key == '1') activeModulsSet = 'A';
  if (key == '2') activeModulsSet = 'B';
  if (key == '3') activeModulsSet = 'C';
  if (key == '4') activeModulsSet = 'D';
  if (key == '5') activeModulsSet = 'E';
  if (key == '6') activeModulsSet = 'F';
  if (key == '7') activeModulsSet = 'G';
  if (key == '8') activeModulsSet = 'H';
  
  if (key == 'y' || key == 'Y') activeTileColor = color(0);
  if (key == 'x' || key == 'X') activeTileColor = color(52, 100, 71);
  if (key == 'c' || key == 'C') activeTileColor = color(192, 100, 64);
  if (key == 'v' || key == 'V') activeTileColor = color(273, 73, 51);
  if (key == 'b' || key == 'B') activeTileColor = color(323, 100, 77);
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}














