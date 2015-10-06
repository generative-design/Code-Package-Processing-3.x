// M_3_4_01_TOOL.pde
// GUI.pde, Mesh.pde, TileSaver.pde
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
 * with this tool, you can play around with a single mesh
 * and lots of drawing parameters
 *
 * MOUSE
 * right click + drag  : rotate
 *
 * KEYS
 * m                   : menu open/close
 * s                   : save png
 * p                   : high resolution export (please update to processing 1.0.8 or 
 *                       later. otherwise this will not work properly)
 * d                   : 3d export (dxf format - will not export colors)
 */


// ------ imports ------

import processing.opengl.*;
import processing.dxf.*;
import java.util.Calendar;


// ------ initial parameters and declarations ------

Mesh myMesh;

int form = Mesh.FIGURE8TORUS;
float meshAlpha = 100;
float meshSpecular = 100;
float meshScale = 100;

boolean drawTriangles = true;
boolean drawQuads = false;
boolean drawNoStrip = true;
boolean drawStrip = false;
boolean useNoBlend = true;
boolean useBlendWhite = false;
boolean useBlendBlack = false;

int uCount = 50;
float uCenter = 0;
float uRange = TWO_PI;

int vCount = 50;
float vCenter = 0;
float vRange = TWO_PI;

float paramExtra = 1;

float meshDistortion = 0;

float minHue = 190;
float maxHue = 195;
float minSaturation = 95;
float maxSaturation = 100;
float minBrightness = 60;
float maxBrightness = 65;


// ------ mouse interaction ------

int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0.5, rotationY = -0.4, targetRotationX = 0.5, targetRotationY = -0.4, clickRotationX, clickRotationY; 


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
int guiEventFrame = 0;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;


// ------ image output ------

boolean saveOneFrame = false;
int qualityFactor = 3;
TileSaver tiler;
boolean saveDXF = false; 




void setup() {
  size(1000, 1000, P3D);

  setupGUI();

  noStroke();

  myMesh = new Mesh(form);

  tiler=new TileSaver(this);
}



void draw() {
  hint(ENABLE_DEPTH_TEST);

  // for high quality output
  if (tiler==null) return; 
  tiler.pre();

  // dxf output
  if (saveDXF) beginRaw(DXF, timestamp()+".dxf");


  // Set general drawing mode
  if (useBlendBlack) background(0);
  else background(255);

  if (useBlendWhite || useBlendBlack) {
  }


  // Set lights
  lightSpecular(255, 255, 255); 
  directionalLight(255, 255, 255, 1, 1, -1); 
  specular(meshSpecular, meshSpecular, meshSpecular); 
  shininess(5.0); 


  // ------ set view ------
  pushMatrix();
  translate(width*0.5, height*0.5);

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


  scale(meshScale);


  // ------ set parameters and draw mesh ------
  myMesh.setForm(form);
  surface.setTitle("Current form: " + myMesh.getFormName());

  if (drawTriangles && drawNoStrip) myMesh.setDrawMode(TRIANGLES);
  else if (drawTriangles && drawStrip) myMesh.setDrawMode(TRIANGLE_STRIP);
  else if (drawQuads && drawNoStrip) myMesh.setDrawMode(QUADS);
  else if (drawQuads && drawStrip) myMesh.setDrawMode(QUAD_STRIP);

  myMesh.setUMin(uCenter-uRange/2);
  myMesh.setUMax(uCenter+uRange/2);
  myMesh.setUCount(uCount);

  myMesh.setVMin(vCenter-vRange/2);
  myMesh.setVMax(vCenter+vRange/2);
  myMesh.setVCount(vCount);

  myMesh.setParam(0, paramExtra);

  myMesh.setColorRange(minHue, maxHue, minSaturation, maxSaturation, minBrightness, maxBrightness, meshAlpha);

  myMesh.setMeshDistortion(meshDistortion);

  myMesh.update();

  colorMode(HSB, 360, 100, 100, 100);

  randomSeed(123);
  myMesh.draw();

  colorMode(RGB, 255, 255, 255, 100);

  popMatrix();


  // ------ image output and gui ------

  // image output
  if (saveOneFrame) {
    saveFrame(timestamp()+".png");
  }

  if (saveDXF) {
    endRaw();
    saveDXF = false;
  }


  // draw gui
  if (tiler.checkStatus() == false) {
    if (useBlendBlack || useBlendWhite) {
    }

    hint(DISABLE_DEPTH_TEST);
    noLights();
    drawGUI();

    if (useBlendWhite || useBlendBlack) {
    }
  }


  // image output
  if (saveOneFrame) {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    saveOneFrame = false;
  }

  // draw next tile for high quality output
  tiler.post();
}




void keyPressed() {
  if (key=='m' || key=='M') {
    GUI = controlP5.getGroup("menu").isOpen();
    GUI = !GUI;
  }
  if (GUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();

  if (key=='s' || key=='S') {
    saveOneFrame = true;
  }
  if (key=='p' || key=='P') {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    if (controlP5.getGroup("menu").isOpen()) controlP5.getGroup("menu").close();
    tiler.init(timestamp()+".png", qualityFactor);
  }
  if (key=='d' || key=='D') {
    saveDXF = true;
  }
}


void mousePressed() {
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
}


void mouseEntered(MouseEvent e) {
  loop();
}

void mouseExited(MouseEvent e) {
  noLoop();
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}