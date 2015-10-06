// M_3_2_03.pde
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
 * draws a grid with a radial wave using u-v-coordinates
 * 
 * MOUSE
 * click + drag        : rotate
 * 
 * KEYS
 * p                   : save pdf (may not look correctly due to missing depth sorting)
 */
 
import processing.opengl.*;
import processing.pdf.*;
import java.util.Calendar;

// grid definition horizontal
int uCount = 40;
float uMin = -10;
float uMax = 10;

// grid definition vertical
int vCount = 40;
float vMin = -10;
float vMax = 10;

// view rotation
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0, rotationY = -1.1, targetRotationX = 0, targetRotationY = -1.1, clickRotationX, clickRotationY; 

// image output
boolean savePDF = false;


void setup() {
  size(800, 800, P3D);
  smooth(8);
}


void draw() {
  if (savePDF) beginRaw(PDF, timestamp()+".pdf");

  background(255);
  fill(255);
  strokeWeight(1/25.0);  

  setView();

  scale(25);

  // draw mesh
  for (float iv = 0; iv < vCount; iv++) {
    beginShape(QUAD_STRIP);
    for (float iu = 0; iu <= uCount; iu++) {
      float u = map(iu, 0, uCount, uMin, uMax);
      float v = map(iv, 0, vCount, vMin, vMax);
      
      float x = u;
      float y = v;
      float z = cos(sqrt(u*u + v*v));
      vertex(x, y, z);

      v = map(iv+1, 0, vCount, vMin, vMax);
      y = v;
      z = cos(sqrt(u*u + v*v));
      vertex(x, y, z);
    }
    endShape();
  }

  // image output
  if(savePDF == true) {
    endRaw();
    savePDF = false;
  }
}


void keyPressed(){
  if(key=='p' || key=='P') savePDF = true; 
}


void mousePressed(){
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
}



void setView() {
  translate(width*0.5,height*0.5);

  if (mousePressed) {
    offsetX = mouseX-clickX;
    offsetY = mouseY-clickY;
    targetRotationX = clickRotationX + offsetX/float(width) * TWO_PI;
    targetRotationY = min(max(clickRotationY + offsetY/float(height) * TWO_PI, -HALF_PI), HALF_PI);
    rotationX += (targetRotationX-rotationX)*0.25; 
    rotationY += (targetRotationY-rotationY)*0.25;  
  }
  rotateX(-rotationY); 
  rotateY(rotationX); 
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}