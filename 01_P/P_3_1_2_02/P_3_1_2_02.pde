// P_3_1_2_02.pde
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
 * typewriter. uses input (text) as blueprint for a visual composition.
 * 
 * MOUSE
 * click + drag        : move canvas
 * 
 * KEYS
 * a-z                 : text input (keyboard)
 * space               : random straight / small curve
 * ,.!?                : curves
 * :+-xz               : icons
 * o                   : station with the last 7 typed letters as name
 * a u                 : stop
 * del, backspace      : remove last letter
 * arrow up            : zoom canvas +
 * arrow down          : zoom canvas -
 * ctrl                : save png + pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;


PFont font;
String textTyped = "Was hier folgt ist Text! So asnt, und mag. Ich mag Text sehr.";

PShape shapeSpace, shapeSpace2, shapePeriod, shapeComma, shapeExclamationmark;
PShape shapeQuestionmark, shapeReturn,  icon1, icon2, icon3, icon4, icon5;

int centerX = 0, centerY = 0, offsetX = 0, offsetY = 0;
float zoom = 0.75;

color[] palette = {
  color(253, 195, 0), color(0), color(0, 158, 224), color(99, 33, 129), 
  color(121, 156, 19), color(226, 0, 26), color(224, 134, 178)};
int actColorIndex = 0;


void setup() {
  size(800, 600);
  // make window resizable
  surface.setResizable(true); 

  centerX = width/2;
  centerY = height/2;  

  font = createFont("miso-bold.ttf",10);
  //font = createFont("Arial",10);

  shapeSpace = loadShape("space.svg");
  shapeSpace2 = loadShape("space2.svg");
  shapePeriod = loadShape("period.svg");
  shapeComma = loadShape("comma.svg"); 
  shapeExclamationmark = loadShape("exclamationmark.svg");
  shapeQuestionmark = loadShape("questionmark.svg");
  shapeReturn = loadShape("return.svg");
  icon1 = loadShape("icon1.svg");
  icon2 = loadShape("icon2.svg");
  icon3 = loadShape("icon3.svg");
  icon4 = loadShape("icon4.svg");
  icon5 = loadShape("icon5.svg");

  shapeSpace.disableStyle();
  shapeSpace2.disableStyle();
  shapePeriod.disableStyle();
  shapeComma.disableStyle();
  shapeExclamationmark.disableStyle();
  shapeQuestionmark.disableStyle();
  shapeReturn.disableStyle();

  cursor(HAND);
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);
  smooth();
  noStroke();
  textAlign(LEFT);

  if (mousePressed == true) {
    centerX = mouseX-offsetX;
    centerY = mouseY-offsetY;
  } 

  translate(centerX,centerY);
  scale(zoom);

  pushMatrix();

  randomSeed(0);

  actColorIndex = 0;
  fill(palette[actColorIndex]);
  rect(0, -25, 10, 35);

  for (int i = 0; i < textTyped.length(); i++) {
    float fontSize = 25;
    textFont(font,fontSize);
    char letter = textTyped.charAt(i);
    float letterWidth = textWidth(letter);

    // ------ letter rule table ------
    switch(letter) {
    case ' ': // space
      // 60% noturn, 20% left, 20% right
      int dir = floor(random(0, 5)); 
      if(dir == 0){
        shape(shapeSpace, 0, 0);
        translate(1.9 ,0);
        rotate(PI/4);
      }
      if(dir == 1){
        shape(shapeSpace2, 0, 0);
        translate( 13 ,-5);
        rotate(-PI/4);
      }
      break;

    case ',': 
      shape(shapeComma, 0, 0);
      translate(34, 15);
      rotate(PI/4);
      break;

    case '.':
      shape(shapePeriod, 0, 0);
      translate(56, -54);
      rotate(-PI/2);
      break;

    case '!':    
      shape(shapeExclamationmark, 0, 0);
      translate(42, -17.4);
      rotate(-PI/4);
      break;

    case '?':
      shape(shapeQuestionmark, 0, 0);
      translate(42, -18);
      rotate(-PI/4);
      break;

    case '\n': // return
      // start a new line at a random position near the center
      rect(0,-25,10,35);
      popMatrix();
      pushMatrix();
      translate(random(-300,300), random(-300,300));
      rotate(floor(random(8))*PI/4);
      // choose nest color from the palette
      actColorIndex = (actColorIndex+1) % palette.length;
      fill(palette[actColorIndex]);
      rect( 0,-25,10,35);
      break;

    case 'o': // Station big
      rect(0,0-15,letterWidth+1,15);
      pushStyle();
      fill(0);
      String station = textTyped.substring(i-10,i-1);
      station = station.toLowerCase();
      station = station.replaceAll(" ", "");
      station = station.substring(0,1).toUpperCase() + station.substring(1,station.length()-1);
      text(station,-10,40);

      ellipse(-5,-7,33,33);
      fill(255);
      ellipse(-5,-7,25,25);
      popStyle();
      translate(letterWidth, 0);
      break;

    case 'a': // Station small left
      rect(0,0-15,letterWidth+1,25);
      rect(0,0-15,letterWidth+1,15);
      translate(letterWidth, 0);
      break;

    case 'u': // Station small right
      rect(0,0-25,letterWidth+1,25);
      rect(0,0-15,letterWidth+1,15);
      translate(letterWidth, 0);
      break;


    case ':': // icon
      shape(icon1,0,-60,30,30);
      break;

    case '+': // icon
      shape(icon2,0,-60,35,30);
      break;

    case '-': // icon
      shape(icon3,0,-60,30,30);
      break;

    case 'x': // icon
      shape(icon4,0,-60,30,30);
      break;

    case 'z': // icon
      shape(icon5,0,-60,30,30);
      break;

    default: // all others
      //text(letter, 0, 0);

      rect(0,0-15,letterWidth+1,15);
      translate(letterWidth, 0);
      //  rotate(-0.05);

    }

  }

  // blink cursor after text
  fill(200,30,40);
  if (frameCount/6 % 2 == 0) rect(0, 0, 15, 2);

  popMatrix();

  if (savePDF) {
    savePDF = false;
    endRecord();
    saveFrame(timestamp()+".png");
  }
}


void mousePressed(){
  offsetX = mouseX-centerX;
  offsetY = mouseY-centerY;
}


void keyReleased() {
  if (keyCode == CONTROL) savePDF = true;
}

void keyPressed() {
  if (key != CODED) {
    switch(key) {
    case DELETE:
    case BACKSPACE:
      textTyped = textTyped.substring(0,max(0,textTyped.length()-1));
      break;
    case TAB:
      break;
    case ENTER:
    case RETURN:
      // enable linebreaks
      textTyped += "\n";
      break;
    case ESC:
      break;
    default:
      textTyped += key;
    }
  }

  // zoom
  if (keyCode == UP) zoom += 0.05;
  if (keyCode == DOWN) zoom -= 0.05;  
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}