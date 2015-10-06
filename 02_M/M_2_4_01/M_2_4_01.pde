// M_2_4_01.pde
// TileSaver.pde
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
 * draws a three dimensional lissajous curve
 *
 * MOUSE
 * right click + drag  : camera controls
 *
 * KEYS
 * 1/2                 : frequency x -/+
 * 3/4                 : frequency y -/+
 * 5/6                 : frequency z -/+
 * arrow left/right    : phi x -/+
 * arrow down/up       : phi y -/+
 * s                   : save png
 * p                   : high resolution export (please update to processing 1.0.8 or 
 *                       later. otherwise this will not work properly)
 */

import processing.opengl.*;
import java.util.Calendar;

int pointCount = 600;
int freqX = 1;
int freqY = 4;
int freqZ = 2;
float phiX = 0;
float phiY = 0;

PVector lissajousPoints[];


// ------ mouse interaction ------
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, zoom=-400;
float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 

// ------ image output ------
boolean saveOneFrame = false;
int qualityFactor = 3;
TileSaver tiler;


void setup() {
  size(600, 600, P3D);

  tiler = new TileSaver(this);

  calculateLissajousPoints();
}


void draw() {
  // for high quality output
  if(tiler==null) return; 
  tiler.pre();

  background(255);
  lights();

  // ------ set view ------
  translate(width/2, height/2, zoom); 
  if (mousePressed && mouseButton==RIGHT) {
    offsetX = mouseX-clickX;
    offsetY = mouseY-clickY;
    targetRotationX = min(max(clickRotationX + offsetY/float(width) * TWO_PI, -HALF_PI), HALF_PI);
    targetRotationY = clickRotationY + offsetX/float(height) * TWO_PI;
  }
  rotationX += (targetRotationX-rotationX)*0.25; 
  rotationY += (targetRotationY-rotationY)*0.25;  
  rotateX(-rotationX);
  rotateY(rotationY); 


  // ------ draw triangles ------
  noStroke();
  beginShape(TRIANGLE_FAN);  
  for(int i=0; i<pointCount-2; i++) {
    if (i%3 == 0) {
      //gradient for every trinangle to lissajou path
      fill(50);
      vertex(0, 0, 0);
      fill(200);
      vertex(lissajousPoints[i].x,lissajousPoints[i].y,lissajousPoints[i].z);
      vertex(lissajousPoints[i+2].x,lissajousPoints[i+2].y,lissajousPoints[i+2].z);
    }
  }
  endShape();


  // ------ draw lissajous path ------
  stroke(0);
  strokeWeight(1);
  noFill();
  beginShape();
  for (int i=0; i<=pointCount; i++){
    vertex(lissajousPoints[i].x, lissajousPoints[i].y, lissajousPoints[i].z);
  }
  endShape();


  // draw next tile for high quality output
  tiler.post();
}


void calculateLissajousPoints(){
  lissajousPoints = new PVector[pointCount+1];
  float f = width/2;

  for (int i = 0; i <= pointCount; i++){
    float angle = map(i, 0,pointCount, 0,TWO_PI);
    float x = sin(angle*freqX+radians(phiX)) * sin(angle*2) * f;
    float y = sin(angle*freqY+radians(phiY)) * f;
    float z = sin(angle*freqZ) * f;
    lissajousPoints[i] = new PVector(x, y, z);
  }
}


void keyPressed(){
  // if(key == 's' || key == 'S') saveFrame(timestamp()+".png");
  if (key == 's' || key == 'S') saveFrame(freqX+"_"+freqY+"_"+freqZ+"_"+int(phiX)+"_"+int(phiY)+".png");
  // if (key =='p' || key == 'P') tiler.init(timestamp()+".png",qualityFactor);
  if (key == 'p' || key == 'P') tiler.init(freqX+"_"+freqY+"_"+freqZ+"_"+int(phiX)+"_"+int(phiY)+".png",qualityFactor);

  if(key == '1') freqX--;
  if(key == '2') freqX++;
  freqX = max(freqX, 1);

  if(key == '3') freqY--;
  if(key == '4') freqY++;
  freqY = max(freqY, 1);

  if(key == '5') freqZ--;
  if(key == '6') freqZ++;
  freqZ = max(freqZ, 1);

  if (keyCode == LEFT) phiX -= 15;
  if (keyCode == RIGHT) phiX += 15;

  if (keyCode == DOWN) phiY -= 15;
  if (keyCode == UP) phiY += 15;

  calculateLissajousPoints();

  println("freqX: " + freqX + ", freqY: " + freqY + ", freqZ: " + freqZ + ", phiX: " + phiX + ", phiY: " + phiY); 
}


void mousePressed(){
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}




























