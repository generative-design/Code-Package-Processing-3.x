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

void setupGUI(){
  color activeColor = color(0,130,164);
  controlP5 = new ControlP5(this);
  //controlP5.setAutoDraw(false);
  controlP5.setColorActive(activeColor);
  controlP5.setColorBackground(color(170));
  controlP5.setColorForeground(color(50));
  controlP5.setColorLabel(color(50));
  controlP5.setColorValue(color(255));

  ControlGroup ctrl = controlP5.addGroup("menu",15,25,35);
  ctrl.setColorLabel(color(255));
  ctrl.close();

  sliders = new Slider[30];
  ranges = new Range[30];
  toggles = new Toggle[30];

  int left = 0;
  int top = 5;
  int len = 300;

  int si = 0;
  int ri = 0;
  int ti = 0;
  int posY = 0;


  sliders[si++] = controlP5.addSlider("form",0,20,left,top+posY,len,15);
  sliders[si++] = controlP5.addSlider("meshScale",1,300,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("meshCount",1,600,left,top+posY+40,len,15);
  posY += 70;

  toggles[ti] = controlP5.addToggle("drawTriangles",drawTriangles,left+110,top+posY,15,15);
  toggles[ti++].setLabel("Draw Triangles");
  toggles[ti] = controlP5.addToggle("drawQuads",drawQuads,left+110,top+posY+20,15,15);
  toggles[ti++].setLabel("Draw Quads");
  toggles[ti] = controlP5.addToggle("drawNoStrip",drawNoStrip,left+215,top+posY,15,15);
  toggles[ti++].setLabel("Draw No Strip");
  toggles[ti] = controlP5.addToggle("drawStrip",drawStrip,left+215,top+posY+20,15,15);
  toggles[ti++].setLabel("Draw Strip");
  toggles[ti] = controlP5.addToggle("useNoBlend",useNoBlend,left+0,top+posY,15,15);
  toggles[ti++].setLabel("No Blend");
  toggles[ti] = controlP5.addToggle("useBlendWhite",useBlendWhite,left+0,top+posY+20,15,15);
  toggles[ti++].setLabel("Blend on White"); 
  toggles[ti] = controlP5.addToggle("useBlendBlack",useBlendBlack,left+0,top+posY+40,15,15);
  toggles[ti++].setLabel("Blend on Black"); 
  posY += 70;

  sliders[si++] = controlP5.addSlider("meshAlpha",0,100,left,top+posY+0,len,15);
  sliders[si++] = controlP5.addSlider("meshSpecular",0,255,left,top+posY+20,len,15);
  posY += 50;

  ranges[ri++] = controlP5.addRange("hueRange",0,360,minHue,maxHue,left,top+posY+0,len,15);
  ranges[ri++] = controlP5.addRange("saturationRange",0,100,minSaturation,maxSaturation,left,top+posY+20,len,15);
  ranges[ri++] = controlP5.addRange("brightnessRange",0,100,minBrightness,maxBrightness,left,top+posY+40,len,15);
  posY += 70;

  sliders[si++] = controlP5.addSlider("uCount",1,40,left,top+posY,len,15);
  ranges[ri++] = controlP5.addRange("randomURange",-PI,PI,randomUCenter-randomURange/2,randomUCenter+randomURange/2,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("randomUCenterRange",0,20,left,top+posY+40,len,15);
  posY += 70;

  sliders[si++] = controlP5.addSlider("vCount",1,40,left,top+posY,len,15);
  ranges[ri++] = controlP5.addRange("randomVRange",-PI,PI,randomVCenter-randomVRange/2,randomVCenter+randomVRange/2,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("randomVCenterRange",0,20,left,top+posY+40,len,15);
  posY += 70;

  sliders[si++] = controlP5.addSlider("paramExtra",-10,10,left,top+posY,len,15);
  sliders[si++] = controlP5.addSlider("randomScaleRange",1,4,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("meshDistortion",0,2,left,top+posY+40,len,15);
  posY += 70;


  for (int i = 0; i < si; i++) {
    sliders[i].setGroup(ctrl);
    sliders[i].captionLabel().toUpperCase(true);
    sliders[i].captionLabel().style().padding(4,3,3,3);
    sliders[i].captionLabel().style().marginTop = -4;
    sliders[i].captionLabel().style().marginLeft = 0;
    sliders[i].captionLabel().style().marginRight = -14;
    sliders[i].captionLabel().setColorBackground(0x99ffffff);
  }
  for (int i = 0; i < ri; i++) {
    ranges[i].setGroup(ctrl);
    ranges[i].captionLabel().toUpperCase(true);
    ranges[i].captionLabel().style().padding(4,3,3,3);
    ranges[i].captionLabel().style().marginTop = -4;
    ranges[i].captionLabel().setColorBackground(0x99ffffff);
  }
  for (int i = 0; i < ti; i++) {
    toggles[i].setGroup(ctrl);
    toggles[i].setColorLabel(color(50));
    toggles[i].captionLabel().style().padding(4,3,3,3);
    toggles[i].captionLabel().style().marginTop = -20;
    toggles[i].captionLabel().style().marginLeft = 18;
    toggles[i].captionLabel().style().marginRight = 5;
    toggles[i].captionLabel().setColorBackground(0x99ffffff);
  }
}

void drawGUI(){
  controlP5.show();
  //controlP5.hide();  
  controlP5.draw();
}


void updateColors(int stat) {
  ControllerGroup ctrl = controlP5.getGroup("menu");

  for (int i = 0; i < sliders.length; i++) {
    if (sliders[i] == null) break;
    if (stat == 0) {
      sliders[i].setColorLabel(color(50));
      sliders[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      sliders[i].setColorLabel(color(200));
      sliders[i].captionLabel().setColorBackground(0x99000000);
    }
  }
  for (int i = 0; i < ranges.length; i++) {
    if (ranges[i] == null) break;
    if (stat == 0) {
      ranges[i].setColorLabel(color(50));
      ranges[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      ranges[i].setColorLabel(color(200));
      ranges[i].captionLabel().setColorBackground(0x99000000);
    }
  }
  for (int i = 0; i < toggles.length; i++) {
    if (toggles[i] == null) break;
    if (stat == 0) {
      toggles[i].setColorLabel(color(50));
      toggles[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      toggles[i].setColorLabel(color(200));
      toggles[i].captionLabel().setColorBackground(0x99000000);
    }
  }
}



void controlEvent(ControlEvent theControlEvent) {
  guiEventFrame = frameCount;

  GUI = controlP5.group("menu").isOpen();

  if(theControlEvent.isController()) {
    if(theControlEvent.controller().name().equals("randomURange")) {
      float[] f = theControlEvent.controller().arrayValue();
      randomUCenter = (f[0] + f[1]) / 2;
      randomURange = f[1] - f[0];
    }
    if(theControlEvent.controller().name().equals("randomVRange")) {
      float[] f = theControlEvent.controller().arrayValue();
      randomVCenter = (f[0] + f[1]) / 2;
      randomVRange = f[1] - f[0];
    }
    if(theControlEvent.controller().name().equals("hueRange")) {
      float[] f = theControlEvent.controller().arrayValue();
      minHue = f[0];
      maxHue = f[1];
    }
    if(theControlEvent.controller().name().equals("saturationRange")) {
      float[] f = theControlEvent.controller().arrayValue();
      minSaturation = f[0];
      maxSaturation = f[1];
    }
    if(theControlEvent.controller().name().equals("brightnessRange")) {
      float[] f = theControlEvent.controller().arrayValue();
      minBrightness = f[0];
      maxBrightness = f[1];
    }
  }
}




void drawTriangles() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    drawTriangles = !drawTriangles;
    drawQuads = !drawTriangles;
    toggles[1].setState(drawQuads);
  }
}

void drawQuads() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    drawQuads = !drawQuads;
    drawTriangles = !drawQuads;
    toggles[0].setState(drawTriangles);
  }
}


void drawNoStrip() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    drawNoStrip = !drawNoStrip;
    drawStrip = !drawNoStrip;
    toggles[3].setState(drawStrip);
  }
}

void drawStrip() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    drawStrip = !drawStrip;
    drawNoStrip = !drawStrip;
    toggles[2].setState(drawNoStrip);
  }
}


void useNoBlend() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    useNoBlend = !useNoBlend;
    if (useNoBlend) {
      useBlendWhite = false;
      useBlendBlack = false;
      toggles[5].setState(useBlendWhite);
      toggles[6].setState(useBlendBlack);
    } 
    else {
      useBlendWhite = true;
      useBlendBlack = false;
      toggles[5].setState(useBlendWhite);
      toggles[6].setState(useBlendBlack);
    }
    updateColors(0);
  }
}

void useBlendWhite() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    useBlendWhite = !useBlendWhite;
    if (useBlendWhite) {
      useNoBlend = false;
      useBlendBlack = false;
      toggles[4].setState(useNoBlend);
      toggles[6].setState(useBlendBlack);
    } 
    else {
      useNoBlend = true;
      useBlendBlack = false;
      toggles[4].setState(useNoBlend);
      toggles[6].setState(useBlendBlack);
    }
    updateColors(0);
  }
}

void useBlendBlack() {
  if (frameCount > guiEventFrame+1) {
    guiEventFrame = frameCount;
    useBlendBlack = !useBlendBlack;
    if (useBlendBlack) {
      useNoBlend = false;
      useBlendWhite = false;
      toggles[4].setState(useNoBlend);
      toggles[5].setState(useBlendWhite);
      updateColors(1);
    } 
    else {
      useNoBlend = true;
      useBlendWhite = false;
      toggles[4].setState(useNoBlend);
      toggles[5].setState(useBlendWhite);
      updateColors(0);
    }
  }
}


