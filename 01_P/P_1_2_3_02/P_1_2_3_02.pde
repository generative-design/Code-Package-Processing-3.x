// P_1_2_3_02.pde
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
 * generates a specific color palette and some random "rect-tilings"
 * 
 * MOUSE
 * left click          : new composition
 * 
 * KEYS
 * s                   : save png
 * p                   : save pdf
 * c                   : save color palette
 */

import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int colorCount = 20;
int[] hueValues = new int[colorCount];
int[] saturationValues = new int[colorCount];
int[] brightnessValues = new int[colorCount];


void setup() {
  size(800,800); 
  colorMode(HSB,360,100,100,100);
  noStroke();
}


void draw() { 
  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
    noStroke();
    colorMode(HSB,360,100,100,100);
  } 
  
  // ------ colors ------
  // create palette
  for (int i=0; i<colorCount; i++) {
    if (i%2 == 0) {
      hueValues[i] = (int) random(0,360);
      saturationValues[i] = 100;
      brightnessValues[i] = (int) random(0,100);
    } 
    else {
      hueValues[i] = 195;
      saturationValues[i] = (int) random(0,100);
      brightnessValues[i] = 100;
    }
  }

  // ------ area tiling ------
  // count tiles
  int counter = 0;
  // row count and row height
  int rowCount = (int)random(5,40);
  float rowHeight = (float)height/(float)rowCount;

  for(int i=0; i<rowCount; i++) {
    // seperate each line in parts  
    // how many fragments
    int partCount = i+1;
    float[] parts = new float[0];

    for(int ii=0; ii<partCount; ii++) {
      // sub fragments or not?
      if (random(1.0) < 0.075) {
        // take care of big values      
        int fragments = (int)random(2,20);
        partCount = partCount + fragments; 
        for(int iii=0; iii<fragments; iii++) {
          parts = append(parts, random(2));
        }              
      }  
      else {
        parts = append(parts, random(2,20));   
      }
    }

    // add all subparts
    float sumPartsTotal = 0;
    for(int ii=0; ii<partCount; ii++) sumPartsTotal += parts[ii];

    // draw rects
    float sumPartsNow = 0;
    for(int ii=0; ii<parts.length; ii++) {
      // get component color values
      int index = counter % colorCount;
      fill(hueValues[index],saturationValues[index],brightnessValues[index]);

      sumPartsNow += parts[ii];
      rect(map(sumPartsNow, 0,sumPartsTotal, 0,width),rowHeight*i, 
      map(parts[ii], 0,sumPartsTotal, 0,width)*-1,rowHeight);

      counter++;
    }
  }  

  if (savePDF) {
    savePDF = false;
    endRecord();
  }

  noLoop();
} 


void mouseReleased() {
  loop();
}


void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  if (key == 'p' || key == 'P') savePDF = true;
  if (key == 'c' || key == 'C') {
    // ------ save an ase file (adobe swatch export) ------
    // create palette
    color[] colors = new color[colorCount];
    for (int i=0; i<colorCount; i++) {
      colors[i] = color(hueValues[i], saturationValues[i], brightnessValues[i]);
    }
    GenerativeDesign.saveASE(this, colors, timestamp()+".ase");
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}









