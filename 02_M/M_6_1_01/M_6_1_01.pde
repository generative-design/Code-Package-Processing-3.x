// M_6_1_01.pde
// Node.pde
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
 * distribute nodes on the display by letting them repel each other
 *
 * KEYS
 * r             : reset positions
 * s             : save png
 */

import java.util.Calendar;

// an array for the nodes
Node[] nodes = new Node[200];


void setup() {
  size(800, 800);
  background(255);
  smooth();
  noStroke();

  // init nodes
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i] = new Node(width/2+random(-1, 1), height/2+random(-1, 1));
    nodes[i].setBoundary(5, 5, width-5, height-5);
  } 
}


void draw() {
  fill(255, 20);
  rect(0, 0, width, height);

  // let all nodes repel each other
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].attract(nodes);
  } 
  // apply velocity vector and update position
  for (int i = 0 ; i < nodes.length; i++) {
    nodes[i].update();
  } 

  // draw node
  fill(0);
  for (int i = 0 ; i < nodes.length; i++) {
    ellipse(nodes[i].x, nodes[i].y, 10, 10);
  }
}



void keyPressed(){
  if(key=='s' || key=='S') saveFrame(timestamp()+"_##.png"); 

  if(key=='r' || key=='R') {
    background(255);
    for (int i = 0 ; i < nodes.length; i++) {
      nodes[i].set(width/2+random(-5, 5), height/2+random(-5, 5), 0);
    } 
  }
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}




