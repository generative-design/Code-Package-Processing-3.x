// M_3_4_02.pde
// Mesh.pde
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
 * draws multiple meshes, all parts of a sphere
 * 
 * MOUSE
 * click + drag        : rotate
 */

import processing.opengl.*;
import java.util.Calendar;

// parameters
int meshCount = 6;
Mesh[] myMeshes;

int form = Mesh.SPHERE;

int uCount = 8;
int vCount = 4;

// rotation
int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 

// image output
boolean saveOneFrame = false;


void setup() {
  size(800, 800, P3D);
  smooth(8);
  
  // ------ initialize meshes ------
  myMeshes = new Mesh[meshCount];

  randomSeed(35976);

  for (int i = 0; i < meshCount; i++) {
    float uMin = random(-6, 6);
    float uMax = uMin + random(2, 3);

    float vMin = random(-6, 6);
    float vMax = vMin + random(1, 2);

    myMeshes[i] = new Mesh(form, uCount,vCount, uMin,uMax, vMin,vMax);
    myMeshes[i].setDrawMode(QUAD_STRIP);

    float col = random(160, 240);
    myMeshes[i].setColorRange(col, col, 0, 0, 100, 100, 100);
  }
}


void draw() {
  // ------ setup canvas, lights and view ------
  // setup drawing style 
  background(255);
  strokeWeight(1/130.0);

  setView();

  scale(130);


  // ------ draw meshes ------
  randomSeed(0);
  for (int i = 0; i < meshCount; i++) {
    pushMatrix();
    scale(random(0.9, 1.2));
    myMeshes[i].draw();
    popMatrix();
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