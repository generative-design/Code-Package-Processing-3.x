// M_3_2_05.pde
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
 * optimized code for calculating and drawing a mesh.  
 * 
 * MOUSE
 * click + drag        : rotate
 */

import processing.opengl.*;
import java.util.Calendar;

// grid definition horizontal
int uCount = 30;
float uMin = 0;
float uMax = 5;

// grid definition vertical
int vCount = 30;
float vMin = -1;
float vMax = 1;

// array for the grid points
// initialize array
PVector[][] points = new PVector[vCount+1][uCount+1];

// view rotation
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 


void setup() {
  size(800,800,P3D);
  smooth(8);
  fill(255);
  strokeWeight(1/400.0);

  // fill array
  float u, v;
  for (int iv = 0; iv <= vCount; iv++) {
    for (int iu = 0; iu <= uCount; iu++) {
      u = map(iu, 0, uCount, uMin, uMax);
      v = map(iv, 0, vCount, vMin, vMax);

      points[iv][iu] = new PVector();
      points[iv][iu].x = v;
      points[iv][iu].y = sin(u)*cos(v);
      points[iv][iu].z = cos(u)*cos(v);
    }
  }

}


void draw() {
  background(255);

  setView();

  scale(200);

  // draw mesh
  for (int iv = 0; iv < vCount; iv++) {
    beginShape(QUAD_STRIP);
    for (int iu = 0; iu <= uCount; iu++) {
      vertex(points[iv][iu].x, points[iv][iu].y, points[iv][iu].z);
      vertex(points[iv+1][iu].x, points[iv+1][iu].y, points[iv+1][iu].z);
    }
    endShape();
  }
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