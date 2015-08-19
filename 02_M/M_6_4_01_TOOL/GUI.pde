// M_6_4_01_TOOL.pde
// GUI.pde, WikipediaGraph.pde, WikipediaNode.pde
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
  ctrl.activateEvent(true);
  ctrl.setColorLabel(color(255));
  ctrl.close();

  sliders = new Slider[30];
  ranges = new Range[30];
  toggles = new Toggle[30];
  bangs = new Bang[30];

  int left = 0;
  int top = 5;
  int len = 300;

  int si = 0;
  int ri = 0;
  int ti = 0;
  int bi = 0;
  int posY = 0;


  toggles[ti] = controlP5.addToggle("autoZoom",autoZoom,left,top+posY,15,15);
  toggles[ti++].setLabel("Adjust Zoom Automatically");
  sliders[si++] = controlP5.addSlider("zoom",0.05,1,left,top+posY+20,len,15);
  posY += 50;

  sliders[si++] = controlP5.addSlider("resultCount",1,50,left,top+posY,len,15);
  posY += 30;

  sliders[si++] = controlP5.addSlider("springLength",10,500,left,top+posY,len,15);
  sliders[si++] = controlP5.addSlider("springStiffness",0,1,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("springDamping",0,1,left,top+posY+40,len,15);
  posY += 70;

  sliders[si++] = controlP5.addSlider("nodeRadius",0,500,left,top+posY+0,len,15);
  sliders[si++] = controlP5.addSlider("nodeStrength",0,50,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("nodeDamping",0,1,left,top+posY+40,len,15);
  posY += 70;

  toggles[ti] = controlP5.addToggle("invertBackground",invertBackground,left+0,top+posY,15,15);
  toggles[ti++].setLabel("Invert Background");
  toggles[ti] = controlP5.addToggle("drawFishEyed",drawFishEyed,left+150,top+posY,15,15);
  toggles[ti++].setLabel("Draw Fish-Eyed");
  sliders[si++] = controlP5.addSlider("lineWeight",1,20,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("lineAlpha",0,100,left,top+posY+40,len,15);
  sliders[si++] = controlP5.addSlider("linkColor",0,1,left,top+posY+60,len,15);
  posY += 90;

  //ranges[ri++] = controlP5.addRange("nodeDiameter",0,30,minNodeDiameter,maxNodeDiameter,left,top+posY+0,len,15);
  toggles[ti] = controlP5.addToggle("colorizeNodes",colorizeNodes,left,top+posY,15,15);
  toggles[ti++].setLabel("Colorize Nodes");
  sliders[si++] = controlP5.addSlider("minNodeDiameter",0,60,left,top+posY+20,len,15);
  sliders[si++] = controlP5.addSlider("nodeDiameterFactor",0,100,left,top+posY+40,len,15);
  //sliders[si++] = controlP5.addSlider("nodeColor",0,1,left,top+posY+40,len,15);
  posY += 70;

  toggles[ti] = controlP5.addToggle("showText",showText,left,top+posY,15,15);
  toggles[ti++].setLabel("Show Text");
  toggles[ti] = controlP5.addToggle("showRolloverNeighbours",showRolloverNeighbours,left+100,top+posY,15,15);
  toggles[ti++].setLabel("Show Neighbours on Rollover");
  posY += 30;


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
  for (int i = 0; i < bi; i++) {
    bangs[i].setGroup(ctrl);
    bangs[i].setColorLabel(color(50));
    bangs[i].captionLabel().style().padding(4,3,3,3);
    bangs[i].captionLabel().style().marginTop = -20;
    bangs[i].captionLabel().style().marginLeft = 33;
    bangs[i].captionLabel().style().marginRight = 5;
    bangs[i].captionLabel().setColorBackground(0x99ffffff);
  }

}



void drawGUI(){
  controlP5.show();
  controlP5.draw();
}



void controlEvent(ControlEvent theControlEvent) {
  guiEvent = true;

  GUI = controlP5.group("menu").isOpen();

  if(theControlEvent.isController()) {
    if (theControlEvent.controller().name().equals("editText")) {
      myWikipediaGraph.confirmEdit(theControlEvent.controller().stringValue());
    }
  }
}



void invertBackground() {
  guiEvent = true;
  invertBackground = !invertBackground;
  updateColors(invertBackground);
}



void updateColors(boolean stat) {
  ControllerGroup ctrl = controlP5.getGroup("menu");

  for (int i = 0; i < sliders.length; i++) {
    if (sliders[i] == null) break;
    if (stat == false) {
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
    if (stat == false) {
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
    if (stat == false) {
      toggles[i].setColorLabel(color(50));
      toggles[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      toggles[i].setColorLabel(color(200));
      toggles[i].captionLabel().setColorBackground(0x99000000);
    }
  }
  for (int i = 0; i < bangs.length; i++) {
    if (bangs[i] == null) break;
    if (stat == false) {
      bangs[i].setColorLabel(color(50));
      bangs[i].captionLabel().setColorBackground(0x99ffffff);
    } 
    else {
      bangs[i].setColorLabel(color(200));
      bangs[i].captionLabel().setColorBackground(0x99000000);
    }
  }
}
















