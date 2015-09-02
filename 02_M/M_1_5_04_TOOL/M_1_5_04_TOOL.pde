// M_1_5_04_TOOL.pde
// Agent.pde, GUI.pde
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
 * noise values (noise 3d) are used to animate a bunch of agents.
 * 
 * KEYS
 * m                   : toogle menu open/close
 * 1                   : draw style line
 * 2                   : draw style ellipse
 * backspace           : clear screen
 * s                   : save png
 */

import controlP5.*;
import java.util.Calendar;


// ------ agents ------
Agent[] agents = new Agent[10000]; // create more ... to fit max slider agentsCount
int agentsCount = 2000;
float noiseScale = 100, noiseStrength = 10, noiseStickingRange = 0.4;
float overlayAlpha = 8, agentsAlpha = 90, strokeWidth = 2, agentWidthMin = 1.5, agentWidthMax = 15;
int drawMode = 1;

// ------ ControlP5 ------
ControlP5 controlP5;
boolean showGUI = false;
Slider[] sliders;
Range[] ranges;


void setup() {
  size(1280,800,P2D);

  setupGUI();
  smooth();
  colorMode(HSB, 360, 100, 100);
  for(int i=0; i<agents.length; i++) agents[i] = new Agent();
}


void draw() {
  fill(0,0,100, overlayAlpha);
  noStroke();
  rect(0,0,width,height);

  stroke(0, agentsAlpha);
  //draw agents
  for(int i=0; i<agentsCount; i++) {
    if (drawMode == 1) agents[i].update1();
    else agents[i].update2();
  }
  drawGUI();
}


void keyReleased(){
  if (key=='m' || key=='M') {
    showGUI = controlP5.getGroup("menu").isOpen();
    showGUI = !showGUI;
  }
  if (showGUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();

  if (key == '1') drawMode = 1;
  if (key == '2') drawMode = 2;
  if (key=='s' || key=='S') saveFrame(timestamp()+".png");
  if (key == DELETE || key == BACKSPACE) background(0,0,100);
}

String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}










