// M_1_3_03.pde
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
 * creates a texture based on noise values
 * 
 * MOUSE
 * position x/y        : specify noise input range
 * 
 * KEYS
 * 1-2                 : set noise mode
 * arrow up            : noise falloff +
 * arrow down          : noise falloff -
 * arrow left          : noise octaves -
 * arrow right         : noise octaves +
 * s                   : save png
 */

import java.util.Calendar;

int octaves = 4;
float falloff = 0.5;

int noiseMode = 1;

void setup() {
  size(512,512); 
  smooth();
  cursor(CROSS);
}

void draw() {
  background(0);

  noiseDetail(octaves,falloff);

  int noiseXRange = mouseX/10;
  int noiseYRange = mouseY/10;

  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float noiseX = map(x, 0,width, 0,noiseXRange);
      float noiseY = map(y, 0,height, 0,noiseYRange);

      float noiseValue = 0;
      if (noiseMode == 1) { 
        noiseValue = noise(noiseX,noiseY) * 255;
      } 
      else if (noiseMode == 2) {
        float n = noise(noiseX,noiseY) * 24;
        noiseValue = (n-(int)n) * 255;
      }

      pixels[x+y*width] = color(noiseValue);
    }
  }
  updatePixels();

  println("octaves: "+octaves+" falloff: "+falloff+" noiseXRange: 0-"+noiseXRange+" noiseYRange: 0-"+noiseYRange); 
}

void keyReleased() {  
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == ' ') noiseSeed((int) random(100000));
  if (key == '1') noiseMode = 1;
  if (key == '2') noiseMode = 2;
}

void keyPressed() {
  if (keyCode == UP) falloff += 0.05;
  if (keyCode == DOWN) falloff -= 0.05;
  if (falloff > 1.0) falloff = 1.0;
  if (falloff < 0.0) falloff = 0.0;

  if (keyCode == LEFT) octaves--;
  if (keyCode == RIGHT) octaves++;
  if (octaves < 0) octaves = 0;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

















