// M_5_3_01.pde
// FileSystemItem.pde, SunburstItem.pde
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
 * KEYS
 * o                          : select an input folder
 * 1                          : mappingMode -> last modified
 * 2                          : mappingMode -> file size
 * 3                          : mappingMode -> local level file size
 * p                          : save pdf
 * s                          : save png
 */

import processing.pdf.*;
import java.util.Calendar;
import java.util.Date;
import java.io.File;

boolean savePDF = false;


// ------ default folder path ------
String defaultFolderPath = System.getProperty("user.home")+"/Desktop";


// ------ control parameters ------
float hueStart = 190, hueEnd = 195;
float saturationStart = 90, saturationEnd = 100;
float brightnessStart = 25, brightnessEnd = 85;
float folderBrightnessStart = 25, folderBrightnessEnd = 85;
float fileArcScale = 0.95, folderArcScale = 0.95;

int mappingMode = 1;


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
  colorMode(HSB,360,100,100);
  
  setInputFolder(defaultFolderPath);
}

void draw() {
  if (savePDF) {
    println("\n"+"saving to pdf – starting");
    beginRecord(PDF, timestamp()+".pdf");
  }

  pushMatrix();
  colorMode(HSB,360,100,100);
  background(0,0,100);
  noFill();
  ellipseMode(RADIUS);
  strokeCap(SQUARE);
  smooth();

  translate(width/2,height/2);

  // ------ draw the viz items ------
  for (int i = 0 ; i < sunburst.length; i++) {
    sunburst[i].drawArc(folderArcScale,fileArcScale);
  }

  popMatrix();

  if (savePDF) {
    savePDF = false;
    endRecord();
    println("saving to pdf – done");
  }
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
  return map(theDepth,0,theDepthMax+1,0,height/2);
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

}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
} 



