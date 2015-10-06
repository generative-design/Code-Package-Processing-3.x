// M_2_6_01_TOOL.pde
// GUI.pde
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
 * drawing tool that uses the special drawing method of connecting 
 * all points with every other.
 *
 * MOUSE
 * left click          : set points
 * shift + left click  : remove points
 * right click + drag  : drag canvas
 *
 * KEYS
 * backspace           : delete last point
 * m                   : menu open/close
 * s                   : save png
 * p                   : save pdf
 * i                   : import points from a text file
 * e                   : export points to a text file
 */


// ------ imports ------

import processing.pdf.*;
import java.awt.event.*;
import java.util.Calendar;


// ------ initial parameters and declarations ------

String backgroundImagePath;
PImage backgroundImage;
float imageAlpha = 30;
float eraserRadius = 20;
// minimum distance to previously set point
float minDistance = 10;    

float zoom = 1;
boolean drawing = false;
boolean shiftDown = false;

int pointCount = 0;
ArrayList pointList = new ArrayList();

boolean invertBackground = false;
float lineWeight = 1;
float lineAlpha = 50;

boolean connectAllPoints = true;
float connectionRadius = 150;
int i1 = 0;
float minHueValue = 0;
float maxHueValue = 100;
float saturationValue = 0;
float brightnessValue = 0;
boolean invertHue = false;


// ------ mouse interaction ------

boolean dragging = false;
float offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, clickOffsetX = 0, clickOffsetY = 0;


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
boolean guiEvent = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;
Bang[] bangs;


// ------ image output ------

boolean saveOneFrame = false;
boolean savePDF = false;




void setup() {
  size(800, 800);

  // make window resizable
  // Attention: with Processing 3.0 windows resizing behaves differently than before.
  // You might uncomment the folling line, but the screen will not be updated
  // automativally, when resizing the window.
  //surface.setResizable(true);

  smooth();

  setupGUI();

  background(255);

  guiEvent = false;
}


void draw() {
  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
  }

  colorMode(RGB, 255, 255, 255, 100);

  pushMatrix();
  translate(width/2, height/2);
  scale(zoom);
  translate(-width/2 + offsetX, -height/2 + offsetY);


  if (guiEvent) {
    drawing = false;
  }

  color bgColor = color(255);
  color eraserColor = color(0);
  if (invertBackground) {
    bgColor = color(0);
    eraserColor = color(255);
  } 

  if (guiEvent || saveOneFrame || savePDF || i1 == 0) {
    guiEvent = false;
    i1 = 0;
  }

  // canvas dragging
  if (dragging) {
    offsetX = clickOffsetX + (mouseX - clickX) / zoom;
    offsetY = clickOffsetY + (mouseY - clickY) / zoom;
    i1 = 0;
  }


  // set or delete points
  if (drawing) {
    if (keyPressed && keyCode == SHIFT) {
      // shift pressed -> delete points

      for (int i=pointList.size()-1; i >= 0; i--) {
        PVector p = (PVector) pointList.get(i);
        float x = (mouseX-width/2) / zoom - offsetX + width/2;
        float y = (mouseY-height/2) / zoom -offsetY + height/2;

        if (dist(p.x, p.y, x, y) <= (eraserRadius/zoom)) {
          pointList.remove(i);
        }
      }
      pointCount = pointList.size();

      i1 = 0;
    } 
    else {
      // set points

      float x = (mouseX-width/2) / zoom - offsetX + width/2;
      float y = (mouseY-height/2) / zoom - offsetY + height/2;

      if (pointCount > 0) {
        PVector p = (PVector) pointList.get(pointCount-1);
        if (dist(x, y, p.x, p.y) > (minDistance)) {
          pointList.add(new PVector(x, y));
        }
      } 
      else {
        pointList.add(new PVector(x, y));
      }
      pointCount = pointList.size();
    }
  }


  // ------ draw everything ------
  strokeWeight(lineWeight);
  stroke(0, lineAlpha);
  strokeCap(ROUND);
  noFill();
  tint(255, imageAlpha);

  if (!connectAllPoints || shiftDown || dragging) {
    background(bgColor);
    if (backgroundImage != null && !saveOneFrame && !savePDF) image(backgroundImage, 0, 0);

    // simple drawing method
    colorMode(HSB, 360, 100, 100, 100);

    for (int i=1; i<pointCount; i++) {
      PVector p1 = (PVector) pointList.get(i-1);
      PVector p2 = (PVector) pointList.get(i);
      drawLine(p1, p2);
      i1++;
    }
  } 
  else {
    // drawing method where all points are connected with each other
    // alpha depends on distance of the points  

    // clear background if drawing of the lines will start from the beginning
    if (i1 == 0) {
      background(bgColor);
      if (backgroundImage != null && !saveOneFrame && !savePDF) image(backgroundImage, 0, 0);
    }

    // draw lines not all at once, just the next 100 milliseconds to keep performance
    int drawEndTime = millis() + 100;
    if (saveOneFrame || savePDF) {
      drawEndTime = Integer.MAX_VALUE;
    }

    colorMode(HSB, 360, 100, 100, 100);
    while (i1 < pointCount && millis () < drawEndTime) {
      for (int i2 = 0; i2 < i1; i2++) {
        PVector p1 = (PVector) pointList.get(i1);
        PVector p2 = (PVector) pointList.get(i2);
        drawLine(p1, p2);
      }
      i1++;

      if (savePDF) {
        println("saving to pdf – step " + i1 + "/" + pointCount);
      }
    }
  }

  if (shiftDown || dragging) {
    stroke(0);
    for (int i=0; i<pointCount; i++) {
      PVector p = (PVector) pointList.get(i);
      point(p.x, p.y);
    }
  }

  popMatrix();

  // draw eraser
  if (keyPressed && keyCode == SHIFT) {
    strokeWeight(1);
    stroke(eraserColor);
    noFill();
    ellipse(mouseX, mouseY, eraserRadius*2, eraserRadius*2);
  }


  // ------ image output and gui ------
  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
    println("saving to pdf – done");
    i1 = 0;
  }

  if (saveOneFrame) {
    saveFrame(timestamp()+".png");
  }


  // draw gui
  drawGUI();

  // image output
  if (saveOneFrame) {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    saveOneFrame = false;
  }
}

void drawLine(PVector p1, PVector p2) {
  float d, a, h;
  d = PVector.dist(p1, p2);
  a = pow(1/(d/connectionRadius+1), 6);

  if (d <= connectionRadius) {
    if (!invertHue) {
      h = map(a, 0, 1, minHueValue, maxHueValue) % 360;
    } 
    else {
      h = map(1-a, 0, 1, minHueValue, maxHueValue) % 360;
    }
    stroke(h, saturationValue, brightnessValue, a*lineAlpha + (i1%2 * 2));
    line(p1.x, p1.y, p2.x, p2.y);
  }
}


void reset() {
  pointList.clear();
  pointCount = 0;
  i1 = 0;
  offsetX = 0;
  offsetY = 0;

  // reset controllers
  Range r;
  Toggle t;
  controlP5.getController("imageAlpha").setValue(30.0);
  controlP5.getController("eraserRadius").setValue(20.0);
  controlP5.getController("zoom").setValue(1.0);

  if (invertBackground == true) {
    t = (Toggle) controlP5.getController("invertBackground");
    t.setState(false);
  }  
  controlP5.getController("lineWeight").setValue(1.0);
  controlP5.getController("lineAlpha").setValue(50.0);

  r = (Range) controlP5.getController("hueRange");
  r.setLowValue(0);
  r.setHighValue(100);
  controlP5.getController("saturationValue").setValue(0.0);
  controlP5.getController("brightnessValue").setValue(0.0);
  if (invertHue == true) {
    t = (Toggle) controlP5.getController("invertHue");
    t.setState(false);
  }

  controlP5.getController("connectionRadius").setValue(150.0);

  if (connectAllPoints == false) {
    t = (Toggle) controlP5.getController("connectAllPoints");
    t.setState(true);
  }
}


void selectFile() {
  guiEvent = true;

  // opens file chooser
  selectInput("Select an image file", "fileSelected");
}

void fileSelected(File selection) {
  if (selection != null) {
    backgroundImagePath = selection.getAbsolutePath();
    println(backgroundImagePath);
    backgroundImage = loadImage(backgroundImagePath);
  }
}


void selectFileLoadPoints() {
  guiEvent = true;

  // opens file chooser
  selectInput("Select Text File with Point Information", "loadPointPathSelected");
}

void loadPointPathSelected(File selection) {
  if (selection != null) {
    String loadPointsPath = selection.getAbsolutePath(); 
    String[] pointStrings = loadStrings(loadPointsPath);
    pointCount = 0;
    pointList.clear();
    for (int i=0; i<pointStrings.length; i++) {
      String[] pt = pointStrings[i].split(" ");
      if (pt.length == 2) {
        pointList.add(new PVector(float(pt[0]), float(pt[1]), 1));
        pointCount++;
      } 
      else if (pt.length == 3) {
        pointList.add(new PVector(float(pt[0]), float(pt[1]), float(pt[2])));
        pointCount++;
      }
    }
    i1 = 0;
  }
}



void selectFileSavePoints() {
  guiEvent = true;

  // opens file chooser
  selectOutput("Save Points as Text File", "savePointPathSelected");
}


void savePointPathSelected(File selection) {
  if (selection != null) {
    String savePointsPath = selection.getAbsolutePath(); 
    if (!savePointsPath.endsWith(".txt")) savePointsPath += ".txt";
    String[] pointStrings = new String[pointCount];
    for (int i=0; i<pointCount; i++) {
      PVector p = (PVector) pointList.get(i);
      if (p.z > 0) {
        pointStrings[i] = p.x + " " + p.y + " " + p.z;
      } 
      else {
        pointStrings[i] = p.x + " " + p.y + " " + 1;
      }
    }
    saveStrings(savePointsPath, pointStrings);
  }
}


void keyPressed() {

  if (key=='m' || key=='M') {
    GUI = controlP5.getGroup("menu").isOpen();
    GUI = !GUI;
    guiEvent = true;
  }
  if (GUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();

  if (key=='s' || key=='S') {
    saveOneFrame = true;
  }
  if (key=='p' || key=='P') {
    savePDF = true; 
    saveOneFrame = true; 
    println("saving to pdf - starting");
  }
  if (keyCode==BACKSPACE) {
    pointCount -= 1;
    pointCount = max(pointCount, 0);
    pointList.remove(pointCount);
    i1 = 0;
  }
  if (keyCode==SHIFT) {
    shiftDown = true;
  }

  if (key=='e' || key=='E') {
    selectFileSavePoints();
  }
  if (key=='i' || key=='I') {
    selectFileLoadPoints();
  }
}

void keyReleased() {
  if (shiftDown) {
    shiftDown = false;
    i1 = 0;
  }
}


void mousePressed() {
  if (mouseButton==LEFT && !guiEvent) {
    drawing = true;
  }

  if (mouseButton==RIGHT) {
    dragging = true;
    clickX = mouseX;
    clickY = mouseY;
    clickOffsetX = offsetX;
    clickOffsetY = offsetY;
  }
}


void mouseReleased() {
  guiEvent = false;
  drawing = false;

  if (dragging) {
    dragging = false;
    i1 = 0;
  }
}



String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}