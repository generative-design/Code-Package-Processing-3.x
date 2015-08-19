// P_3_0_01.pde
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
 * changing the size and the position of a letter
 * 	 
 * MOUSE
 * position x          : size
 * position y          : position
 * drag                : draw
 * 
 * KEYS
 * a-z                 : change letter
 * ctrl                : save png
 */


import java.util.Calendar;

PFont font;
String letter = "A";


void setup(){
  size(800, 800);
  background(255);
  fill(0);

  font = createFont("Arial", 12);
  textFont(font);
  textAlign(CENTER, CENTER);
}

void draw(){
}

void mouseMoved(){
  background(255);
  textSize((mouseX-width/2)*5+1);
  text(letter, width/2, mouseY);
}

void mouseDragged(){
  textSize((mouseX-width/2)*5+1);
  text(letter, width/2, mouseY);
}

void keyReleased() {
  if (keyCode == CONTROL) saveFrame(timeStamp()+"_##.png");

  if (key != CODED && (int)key > 32) letter = str(key);
}


// timestamp
String timeStamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}


