// Cover.pde
// ImageRibbon.pde, Tag.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Groß, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Groß, Julia Laub, Claudius Lazzeroni
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
 * an ImageRibbon represents an elasic line made of nodes and springs.
 * we've built in nodes and springs to have the possibility to implement attraction
 * or repulsion, but this was not used in the end.
 * the colors of the line are defined by the pixels of an image.
 */


class ImageRibbon {
  PApplet parent;

  int count; 
  Node[] nodes;
  Spring[] springs;

  PImage sourceImage;
  color[] colors;

  XML xml;

  int pageInSection;
  int stripIndex;

  // drawing of colors in strip:  1: normal, -1: reversed, 0: back and forth
  int direction = 1;

  // number of points that are used to draw a spring  
  int detail = 20;

  ImageRibbon () {
  }

  ImageRibbon (PApplet theApplet, PVector[] initPoints, PImage theImage, XML theXML, int thePageInSection, int theStripIndex) {
    parent = theApplet;
    count = initPoints.length; 
    sourceImage = theImage;
    xml = theXML;
    pageInSection = thePageInSection;
    stripIndex = theStripIndex;

    int c1 = 0;
    int c2 = 0;
    int c3 = 0;
    colors = new color[count*detail];
    int w = sourceImage.width;
    int h = sourceImage.height;
    float step = (w*h) / float(count*detail);
    for (int i = 0; i < count*detail; i++) {
      colors[i] = sourceImage.pixels[int(i*step)];
    }

    colors = GenerativeDesign.sortColors(parent, colors, GenerativeDesign.GRAYSCALE);

    nodes = new Node[count];
    springs = new Spring[count-1];

    for(int i=0; i<count; i++) {
      nodes[i] = new Node(initPoints[i].x, initPoints[i].y, initPoints[i].z);
      nodes[i].strength = -0.05;
    }
    for(int i=0; i<count-1; i++) {
      springs[i] = new Spring(nodes[i], nodes[i+1]);
      springs[i].length = 2;
    }
  }


  void attract(Node[] theNodes) {
    for(int i = 0; i < count; i++) {
      nodes[i].attract(theNodes);
    }
  }


  void update() {
    for(int i=0; i<count-1; i++) {
      //springs[i].update();
    }
    for(int i=1; i<count-1; i++) {
      nodes[i].update(true, false, true);
    }
  }


  void draw() {
    pushStyle();
    colorMode(HSB, 360, 1, 1, 255);

    noStroke();

    float oldX = nodes[0].x;
    float oldY = nodes[0].y;
    float oldX1 = nodes[0].x;
    float oldY1 = nodes[0].y-0.5;
    float oldX2 = nodes[0].x;
    float oldY2 = nodes[0].y+0.5;

    int c1j = 0;
    int a1j = 0;
    int a2j = 0;
    int c2j = 0;
    float posX = 0;
    float posY = 0;


    for (int j = 0; j < count-1; j++) {
      for (int i = 0; i < detail; i++) {

        float t_all = map(j*detail+i, 0,count*detail, 0,1);
        float t = map(i, 0,detail, 0,1);

        c1j = max(j-1, 0);
        a1j = j;
        a2j = min(j+1, count-1);
        c2j = min(j+2, count-1);
        posX = curvePoint(nodes[c1j].x, nodes[a1j].x, nodes[a2j].x, nodes[c2j].x, t);
        posY = curvePoint(nodes[c1j].y, nodes[a1j].y, nodes[a2j].y, nodes[c2j].y, t);


        color c = color (0);
        float a = 1;

        int ci = count*detail - (j*detail+i) - 1;
        if (direction == -1) ci = colors.length - ci - 1;
        if (direction == 0) {
          if (ci < colors.length/2.0) ci = (int) map(ci, 0,colors.length/2.0, colors.length-1,0);
          else ci = (int) map(ci, colors.length/2.0,colors.length-1, 0,colors.length-1);
        }

        c = colors[ci];
        a = sqrt(sq(saturation(c)) + sq(1-brightness(c)));
        a = min(a, 1) * 255;
        fill(c, a);


        float dx = posX - oldX;
        float dy = posY - oldY;
        PVector n = new PVector(-dy, dx);
        n.normalize();
        float f = map(t_all, 0,1, 1.5,0.5) * qf / 2;
        n.x *= f;
        n.y *= f;

        if (j == 0 && i <= 1) {
          oldX = nodes[0].x;
          oldY = nodes[0].y;
          oldX1 = nodes[0].x-n.x;
          oldY1 = nodes[0].y-n.y;
          oldX2 = nodes[0].x+n.x;
          oldY2 = nodes[0].y+n.y;
        }

        beginShape();
        vertex(oldX1, oldY1);
        vertex(posX-n.x, posY-n.y);
        vertex(posX+n.x, posY+n.y);
        vertex(oldX2, oldY2);
        endShape();

        oldX = posX;
        oldY = posY;
        oldX1 = posX-n.x;
        oldY1 = posY-n.y;
        oldX2 = posX+n.x;
        oldY2 = posY+n.y;
      }
    }
    popStyle();
  }


  void drawEndPoint() {
    noStroke();

    int j = count-2;
    int i = detail-1;

    float posX = nodes[j+1].x;
    float posY = nodes[j+1].y;

    color c = color (0);
    float a = 1;

    int ci = count*detail - (j*detail+i) - 1;
    if (direction == -1) ci = colors.length - ci - 1;
    if (direction == 0) {
      if (ci < colors.length/2.0) ci = (int) map(ci, 0,colors.length/2.0, colors.length-1,0);
      else ci = (int) map(ci, colors.length/2.0,colors.length-1, 0,colors.length-1);
    }

    c = colors[ci];
    a = red(c)*0.3 + green(c)*0.59 + blue(c)*0.11;
    fill(c, (255-a));

    ellipse(posX, posY, 4, 4);

  }
}







































