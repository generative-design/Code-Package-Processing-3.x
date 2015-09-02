// P_4_2_2_02.pde
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
 * timelapse camera. after each intervalTime a picture is saved to the sketch folder
 * 
 */

import processing.video.*; 
import java.util.Calendar;

Capture myCam; 

// intervalTime in sec. here 5 min
int intervalTime = 5*60;

int secondsSinceStart = 0;
String startTime = getTimestamp();
int counter = 0;
boolean doSave = true;

void setup() { 
  size(640, 480); 
  println(Capture.list());
  //String s = "Logitech QuickCam Messenger-WDM"; 
  //myCam = new Capture(this, s, width, height, 30);
  myCam = new Capture(this, width, height, 30);
  myCam.start();
  
  noStroke();
} 

void draw() { 
  if(myCam.available()) { 
    myCam.read();
    image(myCam, 0, 0); 

    secondsSinceStart = millis() / 1000; 
    int interval = secondsSinceStart % intervalTime;

    if (interval == 0 && doSave == true) {
      String saveFileName = startTime+"-"+nf(counter,5);
      saveFrame(saveFileName+".png");
      doSave = false;
      counter++; 
    } 
    else if (interval != 0) {
      doSave = true;
    }

    // visualize the time to the next shot
    fill(random(0,255),random(0,255),random(0,255));
    rect(map(interval, 0,intervalTime, 0,width),0, 5,5);
  } 
}

String getTimestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}