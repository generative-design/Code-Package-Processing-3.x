// M_5_5_01_TOOL.pde
// FileSystemItem.pde, GUI.pde, SunburstItem.pde
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
  controlP5.setColorCaptionLabel(color(50));
  controlP5.setColorValueLabel(color(255));

  ControlGroup ctrl = controlP5.addGroup("menu",15,25,35);
  ctrl.setColorLabel(color(255));
  ctrl.close();

  sliders = new Slider[10];
  ranges = new Range[10];
  toggles = new Toggle[10];

  int left = 0;
  int top = 5;
  int len = 300;

  int si = 0;
  int ri = 0;
  int ti = 0;
  int posY = 0;

  ranges[ri++] = controlP5.addRange("file hue range",0,360,hueStart,hueEnd,left,top+posY+0,len,15);
  ranges[ri++] = controlP5.addRange("file saturation range",0,100,saturationStart,saturationEnd,left,top+posY+20,len,15);
  ranges[ri++] = controlP5.addRange("file brightness range",0,100,brightnessStart,brightnessEnd,left,top+posY+40,len,15);
  posY += 70;

  ranges[ri++] = controlP5.addRange("folder brightness range",0,100,folderBrightnessStart,folderBrightnessEnd,left,top+posY+0,len,15);
  ranges[ri++] = controlP5.addRange("folder stroke brightness range",0,100,folderStrokeBrightnessStart,folderStrokeBrightnessEnd,left,top+posY+20,len,15);
  posY += 50;

  sliders[si++] = controlP5.addSlider("folderArcScale",0,1,left,top+posY+0,len,15);
  sliders[si++] = controlP5.addSlider("fileArcScale",0,1,left,top+posY+20,len,15);
  posY += 50;

  ranges[ri++] = controlP5.addRange("stroke weight range",0,10,strokeWeightStart,strokeWeightEnd,left,top+posY+0,len,15);
  posY += 30;

  sliders[si++] = controlP5.addSlider("dotSize",0,10,left,top+posY+0,len,15);
  sliders[si++] = controlP5.addSlider("dotBrightness",0,100,left,top+posY+20,len,15);
  posY += 50;

  sliders[si++] = controlP5.addSlider("backgroundBrightness",0,100,left,top+posY+0,len,15);
  posY += 30;

  toggles[ti] = controlP5.addToggle("showArcs",showArcs,left+0,top+posY,15,15);
  toggles[ti++].setLabel("show Arcs");
  toggles[ti] = controlP5.addToggle("showLines",showLines,left+0,top+posY+20,15,15);
  toggles[ti++].setLabel("show Lines");
  toggles[ti] = controlP5.addToggle("useBezierLine",useBezierLine,left+0,top+posY+40,15,15);
  toggles[ti++].setLabel("Bezier / Line");
  toggles[ti] = controlP5.addToggle("useArc",useArc,left+0,top+posY+60,15,15);
  toggles[ti++].setLabel("Arc / Rect");


  for (int i = 0; i < si; i++) {
    sliders[i].setGroup(ctrl);
    sliders[i].setId(i);
    sliders[i].getCaptionLabel().toUpperCase(true);
    sliders[i].getCaptionLabel().getStyle().padding(4,3,3,3);
    sliders[i].getCaptionLabel().getStyle().marginTop = -4;
    sliders[i].getCaptionLabel().getStyle().marginLeft = 0;
    sliders[i].getCaptionLabel().getStyle().marginRight = -14;
    sliders[i].getCaptionLabel().setColorBackground(0x99ffffff);
  }

  for (int i = 0; i < ri; i++) {
    ranges[i].setGroup(ctrl);
    ranges[i].setId(i);
    ranges[i].getCaptionLabel().toUpperCase(true);
    ranges[i].getCaptionLabel().getStyle().padding(4,3,3,3);
    ranges[i].getCaptionLabel().getStyle().marginTop = -4;
    ranges[i].getCaptionLabel().setColorBackground(0x99ffffff);
  }
  for (int i = 0; i < ti; i++) {
    toggles[i].setGroup(ctrl);
    toggles[i].setColorCaptionLabel(color(50));
    toggles[i].getCaptionLabel().getStyle().padding(4,3,3,3);
    toggles[i].getCaptionLabel().getStyle().marginTop = -20;
    toggles[i].getCaptionLabel().getStyle().marginLeft = 18;
    toggles[i].getCaptionLabel().getStyle().marginRight = 5;
    toggles[i].getCaptionLabel().setColorBackground(0x99ffffff);
  }
}

void drawGUI(){
  controlP5.show(); 
  controlP5.draw();
}


// called on every change of the gui
void controlEvent(ControlEvent theControlEvent) {
  //println("got a control event from controller with id "+theControlEvent.getController().getId());
  if(theControlEvent.getController().getName().equals("file hue range")) {
    float[] f = theControlEvent.getController().getArrayValue();
    hueStart = f[0];
    hueEnd = f[1];
  }
  if(theControlEvent.getController().getName().equals("file saturation range")) {
    float[] f = theControlEvent.getController().getArrayValue();
    saturationStart = f[0];
    saturationEnd = f[1];
  }
  if(theControlEvent.getController().getName().equals("file brightness range")) {
    float[] f = theControlEvent.getController().getArrayValue();
    brightnessStart = f[0];
    brightnessEnd = f[1];
  }
  if(theControlEvent.getController().getName().equals("folder brightness range")) {
    float[] f = theControlEvent.getController().getArrayValue();
    folderBrightnessStart = f[0];
    folderBrightnessEnd = f[1];
  }
  if(theControlEvent.getController().getName().equals("folder stroke brightness range")) {
    float[] f = theControlEvent.getController().getArrayValue();
    folderStrokeBrightnessStart = f[0];
    folderStrokeBrightnessEnd = f[1];
  }
  if(theControlEvent.getController().getName().equals("stroke weight range")) {
    float[] f = theControlEvent.getController().getArrayValue();
    strokeWeightStart = f[0];
    strokeWeightEnd = f[1];
  }

  // update vars 
  for (int i = 0 ; i < sunburst.length; i++) {
    sunburst[i].update(mappingMode);
  }
}

















