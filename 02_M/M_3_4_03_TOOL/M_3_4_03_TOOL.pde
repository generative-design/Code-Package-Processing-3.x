// M_3_4_03_TOOL.pde
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
 * with this tool, you can play around with multiple mesh parts
 * and draw them in lots of different ways.
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


// ------ image output ------

// factor for high resolution export
int qualityFactor = 3;                   //// 2 - 10
boolean saveOneFrame = false;
TileSaver tiler;
boolean saveDXF = false; 


// ------ initial parameters and declarations ------

Mesh[] myMeshes = new Mesh[0];

int form = Mesh.FIGURE8TORUS;
float meshSpecular = 150;
int meshCount = 450;

boolean drawTriangles = true;
boolean drawQuads = false;
boolean drawNoStrip = true;
boolean drawStrip = false;
boolean useNoBlend = true;
boolean useBlendWhite = false;
boolean useBlendBlack = false;

float meshAlpha = 30;
float meshScale = 100;

float minHue = 185;
float maxHue = 200;
float minSaturation = 90;
float maxSaturation = 100;
float minBrightness = 60;
float maxBrightness = 70;

int uCount = 1;
float randomUCenter = 0;
float randomUCenterRange = TWO_PI;
float randomURange = 1.8;

int vCount = 30;
float randomVCenter = 0;
float randomVCenterRange = TWO_PI;
float randomVRange = 5;

float paramExtra = 1;
float randomScaleRange = 1.0;
float meshDistortion = 0;


// ------ mouse interaction ------

int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = -0.5, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
int guiEventFrame = 0;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;




void setup() {
  size(1000, 1000, P3D);

  setupGUI(); 

  noStroke();

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

  // Set view
  pushMatrix();

  translate(width*0.5, height*0.5);

  if (mousePressed && mouseButton==RIGHT && frameCount>guiEventFrame+1) {
    offsetX = mouseX-clickX;
    offsetY = mouseY-clickY;

    targetRotationX = clickRotationX + offsetX/float(width) * TWO_PI;
    targetRotationY = min(max(clickRotationY + offsetY/float(height) * TWO_PI, -HALF_PI), HALF_PI);

    rotationX += (targetRotationX-rotationX)*0.25; 
    rotationY += (targetRotationY-rotationY)*0.25;
  }
  rotateX(-rotationY); 
  rotateY(rotationX); 

  scale(meshScale);


  // Generate meshes
  randomSeed(0);

  if (meshCount != myMeshes.length) {
    myMeshes = new Mesh[meshCount];

    for (int i = 0; i < meshCount; i++) {
      myMeshes[i] = new Mesh();
    }
  } 


  // Set parameters and draw meshes
  surface.setTitle("Current form: " + myMeshes[0].getFormName());

  colorMode(HSB, 360, 100, 100, 100);

  for (int i = 0; i < meshCount; i++) {
    pushMatrix();

    scale(random(1/randomScaleRange, randomScaleRange));

    float uCenter = random(randomUCenter-randomUCenterRange/2, randomUCenter+randomUCenterRange/2);
    float uRange = random(randomURange);
    float vCenter = random(randomVCenter-randomVCenterRange/2, randomVCenter+randomVCenterRange/2);
    float vRange = random(randomVRange);

    myMeshes[i].setForm(form);

    if (drawTriangles && drawNoStrip) myMeshes[i].setDrawMode(TRIANGLES);
    else if (drawTriangles && drawStrip) myMeshes[i].setDrawMode(TRIANGLE_STRIP);
    else if (drawQuads && drawNoStrip) myMeshes[i].setDrawMode(QUADS);
    else if (drawQuads && drawStrip) myMeshes[i].setDrawMode(QUAD_STRIP);

    myMeshes[i].setUCount(uCount);
    myMeshes[i].setVCount(vCount);

    myMeshes[i].setUMin(uCenter-uRange/2);
    myMeshes[i].setUMax(uCenter+uRange/2);
    myMeshes[i].setVMin(vCenter-vRange/2);
    myMeshes[i].setVMax(vCenter+vRange/2);

    myMeshes[i].setParam(0, paramExtra);

    float rh = random(minHue, maxHue);
    float rs = random(minSaturation, maxSaturation);
    float rb = random(minBrightness, maxBrightness);
    myMeshes[i].setColorRange(rh, rh, rs, rs, rb, rb, meshAlpha);

    myMeshes[i].setMeshDistortion(meshDistortion);

    myMeshes[i].update();
    myMeshes[i].draw();

    popMatrix();
  }
  colorMode(RGB, 255, 255, 255, 100);

  popMatrix();

  if (useBlendWhite || useBlendBlack) {
  }

  // Image output
  if (saveOneFrame) {
    saveFrame(timestamp()+".png");
  }

  if (saveDXF) {
    endRaw();
    saveDXF = false;
  }


  // Draw GUI
  if (tiler.checkStatus() == false) {
    if (useBlendBlack || useBlendWhite) {
    }

    hint(DISABLE_DEPTH_TEST);
    noLights();
    drawGUI();

    if (useBlendBlack || useBlendWhite) {
    }
  }


  // Image output
  if (saveOneFrame) {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    saveOneFrame = false;
  }

  // Draw next tile for high quality output
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