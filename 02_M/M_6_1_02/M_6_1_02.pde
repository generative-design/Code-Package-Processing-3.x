// M_6_1_02.pde
// Spring.pde
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
 * two nodes and a spring
 *
 * MOUSE
 * click, drag   : postion of one of the nodes
 *
 * KEYS
 * s             : save png
 */


import generativedesign.*;
import java.util.Calendar;

Node nodeA, nodeB;
Spring spring;


void setup() {
  size(600, 600);
  smooth();
  fill(0);

  nodeA = new Node(width/2+random(-50, 50), height/2+random(-50, 50));
  nodeB = new Node(width/2+random(-50, 50), height/2+random(-50, 50));

  nodeA.setDamping(0.1);
  nodeB.setDamping(0.1);

  spring = new Spring(nodeA, nodeB);
  spring.setLength(100);
  spring.setStiffness(0.6);
  spring.setDamping(0.3);
}


void draw() {
  background(255);

  if (mousePressed == true) {
    nodeA.x = mouseX;
    nodeA.y = mouseY;
  }

  // update spring
  spring.update();

  // update node positions
  nodeA.update();
  nodeB.update();


  // draw spring
  stroke(0, 130, 164);
  strokeWeight(4);
  line(nodeA.x, nodeA.y, nodeB.x, nodeB.y);

  // draw nodes
  noStroke();
  fill(0);
  ellipse(nodeA.x, nodeA.y, 20, 20);
  ellipse(nodeB.x, nodeB.y, 20, 20);
}



void keyPressed(){
  if(key=='s' || key=='S') saveFrame(timestamp()+"_##.png"); 
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}


