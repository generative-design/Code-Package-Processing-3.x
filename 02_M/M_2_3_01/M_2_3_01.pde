// M_2_3_01.pde
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
 * draws an amplitude modulated oscillator
 *
 * KEYS
 * i                 : toggle draw info signal 
 * c                 : toggle draw carrier signal
 * 1/2               : info signal frequency -/+ 
 * arrow left/right  : info signal phi -/+
 * 7/8               : carrier signal frequency -/+ (modulation frequency)
 * s                 : save png
 * p                 : save pdf
 */


import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

int pointCount;
int freq = 2;
float phi = 0;
float modFreq = 12;

boolean drawFrequency = true;
boolean drawModulation = true;
boolean drawCombination = true;

float angle;
float y; 


void setup() {
  size(800, 400);
  smooth();

  pointCount = width;
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  strokeWeight(1);
  noFill();

  translate(0, height/2);

  // draw oscillator with freq and phi
  if (drawFrequency) {
    stroke(0, 130, 164);
    beginShape();
    for (int i=0; i<=pointCount; i++) {
      angle = map(i, 0,pointCount, 0,TWO_PI);
      y = sin(angle * freq + radians(phi));
      y = y * (height/4);
      vertex(i, y);
    }
    endShape();
  }

  // draw oscillator with modFreq
  if (drawModulation) {
    stroke(0, 130, 164, 128);
    beginShape();
    for (int i=0; i<=pointCount; i++) {
      angle = map(i, 0,pointCount, 0,TWO_PI);
      y = cos(angle * modFreq);
      y = y * (height/4);
      vertex(i, y);
    }
    endShape();
  }

  // draw both combined
  stroke(0);
  strokeWeight(2);
  beginShape();
  for (int i=0; i<=pointCount; i++) {
    angle = map(i, 0,pointCount, 0,TWO_PI);
    
    float info = sin(angle * freq + radians(phi));
    float carrier = cos(angle * modFreq);
    y = info * carrier;
    
    y = y * (height/4);
    vertex(i, y);
  }
  endShape();


  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}


void keyPressed(){
  if(key == 's' || key == 'S') saveFrame(timestamp()+".png");
  if(key == 'p' || key == 'P') {
    savePDF = true; 
    println("saving to pdf - starting");
  }

  if (key == 'i' || key == 'I') drawFrequency = !drawFrequency;
  if (key == 'c' || key == 'C') drawModulation = !drawModulation;

  if(key == '1') freq--;
  if(key == '2') freq++;
  freq = max(freq, 1);

  if (keyCode == LEFT) phi -= 15;
  if (keyCode == RIGHT) phi += 15;

  if(key == '7') modFreq--;
  if(key == '8') modFreq++;
  modFreq = max(modFreq, 1);
  
  println("freq: " + freq + ", phi: " + phi + ", modFreq: " + modFreq); 
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}



















