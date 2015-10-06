// M_6_2_02.pde
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
 * loads an xml asynchronously, thus not disrupting the animation
 * 
 * MOUSE
 * left click          : starts loading the xml
 */

import generativedesign.*;
import processing.data.XML;


XML myXML;
XML[] links;
String query;

float angle = 0;


void setup() {
  size(200, 200);
  smooth();
  strokeWeight(4);
}


void draw() {
  // some animation
  background(255);
  translate(width/2, height/2);
  rotate(angle);
  angle += 0.02;
  line(-100, 0, 100, 0);

  // test if xml is already loaded
  if (myXML != null) {
    if (myXML.getChildCount() == 0) {
      println("not loaded yet");
    } 
    else {
      links = myXML.getChildren("query/pages/page/links/pl"); 
      for (int i = 0; i < links.length; i++) {
        String title = links[i].getString("title");
        println("Link " + i + ": " + title);    
      }
      myXML = null;
    }
  }
  
} 


void mousePressed() {
  query = "http://en.wikipedia.org/w/api.php?titles=Superegg&format=xml&action=query&prop=links&pllimit=500";
  myXML = GenerativeDesign.loadXMLAsync(this, query);
}