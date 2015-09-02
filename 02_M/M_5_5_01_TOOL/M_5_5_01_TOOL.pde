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

// CREDITS
// part of the FileSystemItem class is based on code from Visualizing Data, First Edition 
// by Ben Fry. Copyright 2008 Ben Fry, 9780596514556.
//
// calcEqualAreaRadius function was done by Prof. Franklin Hernandez-Castro

/**
 * press 'o' to select an input folder!
 * take care of very big folders, loading will take up to several minutes.
 * 
 * program takes a file directory (hierarchical tree) as input 
 * and displays all files and folders with sunburst technique.
 * 
 * MOUSE
 * position x/y               : rollover -> get meta information
 * 
 * KEYS
 * o                          : select an input folder
 * 1                          : mappingMode -> last modified
 * 2                          : mappingMode -> file size
 * 3                          : mappingMode -> local folder file size
 * m                          : toogle, menu open/close
 * s                          : save png
 * p                          : save pdf
 */

import processing.pdf.*;
import controlP5.*;
import java.util.Calendar;
import java.util.Date;
import java.io.File;


// ------ default folder path ------
String defaultFolderPath = System.getProperty("user.home")+"/Desktop";
//String defaultFolderPath = "/Users/admin/Desktop";
//String defaultFolderPath = "C:\\windows";


// ------ ControlP5 ------
ControlP5 controlP5;
boolean showGUI = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;


// ------ interaction vars ------
//float hueStart = 190, hueEnd = 195;
//float hueStart = 320, hueEnd = 325;
//float hueStart = 50, hueEnd = 55;
//float saturationStart = 90, saturationEnd = 100;
//float brightnessStart = 25, brightnessEnd = 85;

float hueStart = 273, hueEnd = 323;
float saturationStart = 73, saturationEnd = 100;
float brightnessStart = 51, brightnessEnd = 77;

float folderBrightnessStart = 20, folderBrightnessEnd = 90;
float folderStrokeBrightnessStart = 20, folderStrokeBrightnessEnd = 90;
float fileArcScale = 1.0, folderArcScale = 0.2;
float strokeWeightStart = 0.5, strokeWeightEnd = 1.0;
float dotSize = 3, dotBrightness = 1;
float backgroundBrightness = 100;

int mappingMode = 1;
boolean useArc = true;
boolean useBezierLine = true;
boolean showArcs = true;
boolean showLines = true;
boolean savePDF = false;

PFont font;

// ------ program logic ------
SunburstItem[] sunburst;
ArrayList tmpSunburstItems;
Calendar now = Calendar.getInstance();
int depthMax;
int lastModifiedOldest, lastModifiedYoungest;
float fileSizeMin, fileSizeMax;
int childCountMin, childCountMax;
int fileCounter = 0;


void setup() { 
  size(1000,800);
  setupGUI(); 
  colorMode(HSB,360,100,100);

  //font = createFont("Arial", 14);
  font = createFont("miso-regular.ttf", 14);
  textFont(font,12);
  textLeading(14);
  textAlign(LEFT, TOP);
  cursor(CROSS);

  frame.setTitle("press 'o' to select an input folder!");
  setInputFolder(defaultFolderPath);
}

void draw() {
  if (savePDF) {
    println("\n"+"saving to pdf – starting");
    beginRecord(PDF, timestamp()+".pdf");
  }

  pushMatrix();
  colorMode(HSB,360,100,100,100);
  background(0,0,backgroundBrightness);
  noFill();
  ellipseMode(RADIUS);
  strokeCap(SQUARE);
  textFont(font,12);
  textLeading(14);
  textAlign(LEFT, TOP);
  smooth();

  translate(width/2,height/2);

  // ------ mouse rollover, arc hittest vars ------
  int hitTestIndex = -1;
  float mX = mouseX-width/2;
  float mY = mouseY-height/2;
  float mAngle = atan2(mY-0, mX-0);
  float mRadius = dist(0,0, mX,mY);

  if (mAngle < 0) mAngle = map(mAngle,-PI,0,PI,TWO_PI);
  else mAngle = map(mAngle,0,PI,0,PI);
  // calc mouse depth with mouse radius ... transformation of calcEqualAreaRadius()
  int mDepth = floor(pow(mRadius,2)*(depthMax+1)/pow(height*0.5,2));


  // ------ draw the viz items ------
  for (int i = 0 ; i < sunburst.length; i++) {
    // draw arcs or rects
    if (showArcs) { 
      if (useArc) sunburst[i].drawArc(folderArcScale,fileArcScale);
      else sunburst[i].drawRect(folderArcScale,fileArcScale);
    }

    // hittest, which arc is the closest to the mouse
    if (sunburst[i].depth == mDepth) {
      if (mAngle > sunburst[i].angleStart && mAngle < sunburst[i].angleEnd) hitTestIndex=i;
    }
  }

  if (showLines) {
    for (int i = 0 ; i < sunburst.length; i++) {
      if (useBezierLine) sunburst[i].drawRelationBezier();
      else sunburst[i].drawRelationLine();
    } 
  }

  for (int i = 0 ; i < sunburst.length; i++) {
    sunburst[i].drawDot();
  }


  // ------ mouse rollover ------
  if (showGUI == false) {
    // depth level focus
    if (mDepth <= depthMax) {
      float r1 = calcEqualAreaRadius(mDepth,depthMax);
      float r2 = calcEqualAreaRadius(mDepth+1,depthMax);
      stroke(0,0,0,30);
      strokeWeight(5.5);
      ellipse(0,0,r1,r1);
      ellipse(0,0,r2,r2);
    }
    // rollover text
    if(hitTestIndex != -1) {
      String tex = sunburst[hitTestIndex].name+"\n";
      tex += nf(sunburst[hitTestIndex].fileSize,1,1)+" MB | ";
      tex += sunburst[hitTestIndex].lastModified+" days | ";
      tex += sunburst[hitTestIndex].childCount+" kids"; 
      float texW = textWidth(tex)*1.2;
      fill(0,0,0);
      int offset = 5;
      rect(mX+offset,mY+offset,texW+4,textAscent()*3.6);
      fill(0,0,100);
      text(tex.toUpperCase(),mX+offset+2,mY+offset+2);
    }
  }


  popMatrix();

  if (savePDF) {
    savePDF = false;
    endRecord();
    println("saving to pdf – done");
  }

  drawGUI();
}


// ------ folder selection dialog + init visualization ------
void setInputFolder(File theFolder) {
  setInputFolder(theFolder.toString());
}

void setInputFolder(String theFolderPath) {
    // get files on harddisk
  println("\n"+theFolderPath);
  FileSystemItem selectedFolder = new FileSystemItem(new File(theFolderPath)); 
  //selectedFolder.printDepthFirst();
  //selectedFolder.printBreadthFirst(); 

  // init sunburst
  sunburst = selectedFolder.createSunburstItems();

  // mine sunburst -> get min and max values 
  // reset the old values, without the root element
  depthMax = 0;
  lastModifiedOldest = lastModifiedYoungest = 0; 
  fileSizeMin = fileSizeMax = 0;
  childCountMin = childCountMax = 0;
  for (int i = 1 ; i < sunburst.length; i++) {
    depthMax = max(sunburst[i].depth, depthMax);
    lastModifiedOldest = max(sunburst[i].lastModified, lastModifiedOldest);
    lastModifiedYoungest = min(sunburst[i].lastModified, lastModifiedYoungest);
    fileSizeMin = min(sunburst[i].fileSize, fileSizeMin);
    fileSizeMax = max(sunburst[i].fileSize, fileSizeMax);
    childCountMin = min(sunburst[i].childCount, childCountMin);
    childCountMax = max(sunburst[i].childCount, childCountMax);
  }

  // update vars 
  for (int i = 0 ; i < sunburst.length; i++) {
    sunburst[i].update(mappingMode);
  }
}


// ------ returns radiuses to have equal areas in each depth ------
float calcEqualAreaRadius (int theDepth, int theDepthMax){
  return sqrt (theDepth * pow(height/2, 2) / (theDepthMax+1));
}

// ------ returns radiuses in a linear way ------
float calcAreaRadius (int theDepth, int theDepthMax){
  return map(theDepth, 0,theDepthMax+1, 0,height/2);
}


// ------ interaction ------
void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  if (key == 'o' || key == 'O') selectFolder("please select a folder", "setInputFolder");

  if (key == '1') {
    mappingMode = 1;
    frame.setTitle("last modified: old / young files, global");
  }  
  if (key == '2') {
    mappingMode = 2;
    frame.setTitle("file size: big / small files, global");
  }  
  if (key == '3') {
    mappingMode = 3;
    frame.setTitle("local folder file size: big / small files, each folder independent");
  }
  if (key == '1' || key == '2' || key == '3') {
    for (int i = 0 ; i < sunburst.length; i++) {
      sunburst[i].update(mappingMode);
    }
  }

  if (key=='m' || key=='M') {
    showGUI = controlP5.getGroup("menu").isOpen();
    showGUI = !showGUI;
  }
  if (showGUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();
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




