// P_3_1_3_04.pde
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
 * analysing and sorting the letters of a text 
 * connecting subsequent letters with lines
 *
 * MOUSE
 * position x          : interpolate between normal text and sorted position
 *
 * KEYS
 * 1                   : toggle grey lines on/off
 * 2                   : toggle colored lines on/off
 * 3                   : toggle text on/off
 * 4                   : switch all letters off
 * 5                   : switch all letters on
 * a-z                 : switch letter on/off
 * ctrl                : save png + pdf
 */

import processing.pdf.*;
import java.util.Calendar;

boolean savePDF = false;

PFont font;
String[] lines;
String joinedText;

String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß,.;:!? ";
int[] counters = new int[alphabet.length()];
boolean[] drawLetters = new boolean[alphabet.length()];

float charSize;
color charColor = 0;
int posX = 20;
int posY = 50;

boolean drawGreyLines = false;
boolean drawColoredLines = true;
boolean drawText = true;


void setup() {
  size(1200, 800);
  lines = loadStrings("faust_kurz.txt");  //laden des zu analysierenden textes
  joinedText = join(lines, " ");

  font = createFont("Courier", 10);

  for (int i = 0; i < alphabet.length(); i++) {
    drawLetters[i] = true;
  }

  countCharacters();
}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  colorMode(HSB, 360, 100, 100, 100);
  textFont(font);
  background(360);
  noStroke();
  fill(0);
  smooth();

  translate(50, 0);

  posX = 0;
  posY = 200;
  float[] sortPositionsX = new float[alphabet.length()];
  float[] oldPositionsX = new float[alphabet.length()];
  float[] oldPositionsY = new float[alphabet.length()];
  float oldX = 0;
  float oldY = 0;

  // draw counters
  if (mouseX >= width-50) {
    textSize(10);
    for (int i = 0; i < alphabet.length(); i++) {
      textAlign(LEFT);
      text(alphabet.charAt(i), -15, i*20+40);
      textAlign(RIGHT);
      text(counters[i], -20, i*20+40);
    }
  }

  // go through all characters in the text to draw them
  textAlign(LEFT);
  textSize(18);
  
  for (int i = 0; i < joinedText.length(); i++) {
    // again, find the index of the current letter in the alphabet
    String s = str(joinedText.charAt(i)).toUpperCase();
    char uppercaseChar = s.charAt(0);
    int index = alphabet.indexOf(uppercaseChar);
    if (index < 0) continue;

    float m = map(mouseX, 50,width-50, 0,1);
    m = constrain(m, 0, 1);

    float sortX = sortPositionsX[index];
    float interX = lerp(posX, sortX, m);

    float sortY = index*20+40;
    float interY = lerp(posY, sortY, m);

    if (drawLetters[index]) {
      if (drawGreyLines) {
        if (oldX!=0 && oldY!=0) {
          stroke(0, 10);
          line(oldX,oldY, interX,interY);
        }
        oldX = interX;
        oldY = interY;
      }

      if (drawColoredLines) {
        if (oldPositionsX[index]!=0 && oldPositionsY[index]!=0) {
          stroke(index*10, 80, 60, 50);
          line(oldPositionsX[index],oldPositionsY[index], interX,interY);
        }
        oldPositionsX[index] = interX;
        oldPositionsY[index] = interY;
      }

      if (drawText) {
        text(joinedText.charAt(i), interX, interY);
      }
    }
    else {
      oldX = 0;
      oldY = 0;
    }

    sortPositionsX[index] += textWidth(joinedText.charAt(i));
    posX += textWidth(joinedText.charAt(i));
    if (posX >= width-200 && uppercaseChar == ' ') {
      posY += 40;
      posX = 0;
    }
  }

  if (savePDF) {
    savePDF = false;
    endRecord();
  }
}


void countCharacters() {
  for (int i = 0; i < joinedText.length(); i++) {
    // get one char from the text, convert it to a string and turn it to uppercase
    String s = str(joinedText.charAt(i)).toUpperCase();
    // convert it back to a char
    char uppercaseChar = s.charAt(0);
    // get the position of this char inside the alphabet string
    int index = alphabet.indexOf(uppercaseChar);
    // increase the respective counter
    if (index >= 0) counters[index]++;
  }
}


void keyReleased(){
  if (keyCode == CONTROL) {
    saveFrame(timestamp()+"_##.png");
    savePDF = true;
  }

  if (key == '1') drawGreyLines = !drawGreyLines;
  if (key == '2') drawColoredLines = !drawColoredLines;
  if (key == '3') drawText = !drawText;

  if (key == '4') {
    for (int i = 0; i < alphabet.length(); i++) {
      drawLetters[i] = false;
    }
  }
  if (key == '5') {
    for (int i = 0; i < alphabet.length(); i++) {
      drawLetters[i] = true;
    }
  }
  String s = str(key).toUpperCase();
  char uppercaseKey = s.charAt(0);
  int index = alphabet.indexOf(uppercaseKey);
  if (index >= 0) {
    drawLetters[index] = !drawLetters[index];
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}






















































