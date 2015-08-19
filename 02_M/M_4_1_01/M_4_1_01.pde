// M_4_1_01.pde
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
 * some moving nodes
 *
 * KEYS
 * r             : re-initialize velocity vectors of the nodes
 * s             : save png
 */


import java.util.Calendar;

int nodeCount = 20;

// myNodes array 
Node[] myNodes = new Node[nodeCount];


// image output
boolean saveOneFrame = false;



void setup() {
  size(600,600); 
  colorMode(RGB, 255, 255, 255, 100);
  smooth();
  background(255); 
  noStroke();
  fill(0);

  // setup myNodes
  for (int i = 0; i < nodeCount; i++) {
    myNodes[i] = new Node(random(width), random(height));
    myNodes[i].velocity.x = random(-3, 3);
    myNodes[i].velocity.y = random(-3, 3);
    myNodes[i].damping = 0.01;
  }
}

void draw() {
  fill(255, 5);
  rect(0, 0, width, height);


  for (int i = 0; i < myNodes.length; i++) {
    myNodes[i].update();

    // draw node
    fill(0, 100);
    ellipse(myNodes[i].x, myNodes[i].y, 10, 10);
  }


  // image output
  if(saveOneFrame == true) {
    saveFrame("_M_4_1_01_"+timestamp()+".png");
    saveOneFrame = false;
  }
}



void keyPressed(){
  if(key=='r' || key=='R') {
    for (int i = 0; i < nodeCount; i++) {
      myNodes[i].velocity.x = random(-5, 5);
      myNodes[i].velocity.y = random(-5, 5);
    }
  }

  if(key=='s' || key=='S') {
    saveOneFrame = true; 
  }
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}








