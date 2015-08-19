// P_4_3_1_02_analyse_svg_grayscale.pde
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
 * greyscale analyse tool. select a folder with svg files. greyscale values output in console.
 * ATTENTION: svg-files will be renamed!
 * usefull in combination with "_4_3_1_02.pde"
 */

PShape[] shapes;
String[] fileNames;
File dir;
int shapeCount = 0;
int counter = 0;

import java.io.File;


void setup() {
  size(256, 256);
  smooth();
  // ------ load shapes ------
  // replace this location with a folder on your machine
  dir = new File("your/path/to/folder");
  //File dir = new File(sketchPath,"data");
  if (dir.isDirectory()) {
    String[] contents = dir.list();
    shapes = new PShape[contents.length]; 
    fileNames = new String[contents.length];
    for (int i = 0 ; i < contents.length; i++) {
      // skip hidden files and folders starting with a dot, load .png files only
      if (contents[i].charAt(0) == '.') continue;
      else if (contents[i].toLowerCase().endsWith(".svg")) {
        File childFile = new File(dir, contents[i]);        
        shapes[shapeCount] = loadShape(childFile.getPath());
        fileNames[shapeCount] = contents[i];
        shapeCount++;             
      }
    }
  }
  background(255);
}

void draw() {
  background(255);
  shape(shapes[counter], 0, 0, width, height);
  loadPixels();

  float sumR = 0, sumG = 0, sumB = 0;

  for (int i = 0 ; i < pixels.length; i++) {
    // extract red, green, and blue components from pixels[i]
    int r = (pixels[i] >> 16) & 0xFF;
    int g = (pixels[i] >> 8) & 0xFF;
    int b = pixels[i] & 0xFF;
    sumR += r;
    sumG += g;
    sumB += b;
  }

  sumR /= (float)pixels.length;
  sumG /= (float)pixels.length;
  sumB /= (float)pixels.length;
  float averageGreyScale = sumR*0.222 + sumG*0.707 + sumB*0.071;

  println(counter+"  "+fileNames[counter]+"  average greyscale -> "+round(averageGreyScale)+"  "+((1-averageGreyScale/255.0)*100)+ " %");

  // rename files
  String namePrefix = nf(round(averageGreyScale), 3);
  if (!fileNames[counter].startsWith(namePrefix)) {
    File svgFile = new File(dir, fileNames[counter]); 
    String newName = namePrefix + "_" + fileNames[counter];
    boolean res = svgFile.renameTo(new File(dir, newName));
  }

  counter++;
  if (counter >= shapeCount) noLoop();
}











