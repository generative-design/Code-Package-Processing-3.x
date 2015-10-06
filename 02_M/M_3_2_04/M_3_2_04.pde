// M_3_2_04.pde
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
 * draws a mesh using u-v-coordinates. change u and v ranges using different keys
 * 
 * MOUSE
 * click + drag        : rotate
 * 
 * KEYS
 * 1/2                 : uMin -/+
 * 3/4                 : uMax -/+
 * 5/6                 : vMin -/+
 * 7/8                 : vMax -/+
 * arrow left/right    : uMin, uMax -/+ 
 * arrow down/up       : vMin, vMax -/+ 
 * p                   : save pdf (may not look correctly due to missing depth sorting)
 */

import processing.opengl.*;
import processing.pdf.*;
import java.util.Calendar;

// grid definition horizontal
int uCount = 30;
float uMin = 0;
float uMax = 5;

// grid definition vertical
int vCount = 30;
float vMin = -1;
float vMax = 1;

// view rotation
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 1, rotationY = 0.3, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 

// image output
boolean savePDF = false;


void setup() {
  size(800, 800, P3D);
  smooth(8);
}


void draw() {
  String filename = int(uMin*10)+"_"+int(uMax*10)+"_"+int(vMin*10)+"_"+int(vMax*10)+"_";
  if (savePDF) beginRaw(PDF, filename+timestamp()+".pdf");

  background(255);
  fill(255);
  strokeWeight(1/200.0);  

  setView();

  scale(200);

  // draw mesh
  for (float iv = vCount-1; iv >= 0; iv--) {
    beginShape(QUAD_STRIP);
    for (float iu = 0; iu <= uCount; iu++) {
      float u = map(iu, 0, uCount, uMin, uMax);
      float v = map(iv, 0, vCount, vMin, vMax);

      float x = 0.75*v;
      float y = sin(u)*v;
      float z = cos(u)*cos(v);
      vertex(x, y, z);

      v = map(iv+1, 0, vCount, vMin, vMax);
      x = 0.75*v;
      y = sin(u)*v;
      z = cos(u)*cos(v);
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

  if(key=='1') uMin -= 0.1; 
  if(key=='2') uMin += 0.1; 
  if(key=='3') uMax -= 0.1; 
  if(key=='4') uMax += 0.1; 
  if(key=='5') vMin -= 0.1; 
  if(key=='6') vMin += 0.1; 
  if(key=='7') vMax -= 0.1; 
  if(key=='8') vMax += 0.1; 

  if (keyCode == LEFT) { 
    uMin -= 0.1;
    uMax -= 0.1;
  }
  if (keyCode == RIGHT) { 
    uMin += 0.1;
    uMax += 0.1;
  }
  if (keyCode == DOWN) { 
    vMin -= 0.1;
    vMax -= 0.1;
  }
  if (keyCode == UP) { 
    vMin += 0.1;
    vMax += 0.1;
  }

  println("U Range: " + nf(uMin,0,1) + " - " + nf(uMax,0,1) + " | V Range: " + nf(vMin,0,1) + " - " + nf(vMax,0,1)); 
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