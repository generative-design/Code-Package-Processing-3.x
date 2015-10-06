// M_4_4_01_TOOL.pde
// GUI.pde, TileSaver.pde
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
 * play around with a 3d grid of nodes and draw them in different ways
 *
 * MOUSE
 * left click          : apply attractor force (repulsion)
 * shift + left click  : apply attractor force (attraction)
 * right click + drag  : rotate
 *
 * KEYS
 * arrow keys          : rotate
 * m                   : menu open/close
 * r                   : reset
 * s                   : save png
 * p                   : save pdf
 * h                   : save high resolution png (please update to processing 1.0.8 or 
 *                       later. otherwise this will not work properly)
 */


// ------ imports ------

import generativedesign.*;
import processing.opengl.*;
import processing.pdf.*;
import java.util.Calendar;


// ------ initial parameters and declarations ------

color[] defaultColors = {
  color(0, 130, 164)};

color[] colors;

boolean freeze = false;

int maxCount = 50;
int xCount;
int yCount;
int zCount;
int oldXCount;
int oldYCount;
int oldZCount;
float gridStepX;
float gridStepY;
float gridStepZ;
float oldGridStepX;
float oldGridStepY;
float oldGridStepZ;

float attractorRadius = 150;
float attractorStrength = 3;
float attractorRamp = 1;
float nodeDamping = 0.1;

boolean drawX = true;
boolean drawY = true;
boolean drawZ = true;
boolean lockX = false;
boolean lockY = false;
boolean lockZ = false;

boolean invertBackground = false;
float lineWeight = 1;
float lineAlpha = 50;

boolean drawLines = true;
boolean drawCurves = false;

// nodes array
Node[][][] nodes = new Node[maxCount*2+1][maxCount*2+1][maxCount*2+1];

// attraktor 
Attractor myAttractor;


// ------ mouse interaction ------

int offsetX = 0, offsetY = 0, clickX = 0, clickY = 0;
float rotationX = 0, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY; 
boolean mouseInWindow = false;


// ------ ControlP5 ------

import controlP5.*;
ControlP5 controlP5;
boolean GUI = false;
boolean guiEvent = false;
Slider[] sliders;
Range[] ranges;
Toggle[] toggles;
Bang[] bangs;


// ------ image output ------

boolean saveOneFrame = false;
boolean savePDF = false;
int qualityFactor = 3;
TileSaver tiler;


void setup() {
  size(1000, 1000, P3D);
  hint(DISABLE_DEPTH_TEST);

  tiler = new TileSaver(this);

  setupGUI();

  // init attractor
  myAttractor = new Attractor();
  myAttractor.setMode(Attractor.SMOOTH); 

  // init grid
  reset();

  guiEvent = false;
}


void draw() {
  // ------ image output ------
  if(tiler==null) return; 
  tiler.pre();

  if (savePDF) {
    beginRaw(PDF, timestamp()+".pdf");
  }

  colorMode(HSB, 360, 100, 100, 100);

  color bgColor = color(360);
  color circleColor = color(0);
  if (invertBackground) {
    bgColor = color(0);
    circleColor = color(360);
  } 
  background(bgColor);


  noStroke();
  fill(bgColor);
  rect(0, 0, width, height);

  noFill();
  stroke(0, 100);
  strokeWeight(lineWeight);
  if (tiler.checkStatus()) strokeWeight(lineWeight*qualityFactor);
  bezierDetail(10);


  // ------ set view ------
  pushMatrix();
  translate(width/2,height/2);

  if (mousePressed && mouseButton==RIGHT) {
    offsetX = (mouseX-clickX);
    offsetY = -(mouseY-clickY);

    targetRotationX = min(max(clickRotationX + offsetY/float(width) * TWO_PI, -HALF_PI), HALF_PI);
    targetRotationY = clickRotationY + offsetX/float(height) * TWO_PI;
  }
  rotationX += (targetRotationX-rotationX)*0.25; 
  rotationY += (targetRotationY-rotationY)*0.25;  
  rotateX(rotationX);
  rotateY(rotationY); 



  // ------ set parameters ------
  if (xCount != oldXCount || yCount != oldYCount || zCount != oldZCount) {
    //initGrid();
    oldXCount = xCount;
    oldYCount = yCount;
    oldZCount = zCount;
  }

  if (nodes[0][0][0].damping != nodeDamping) {
    updateDamping();
  }


  myAttractor.radius = attractorRadius;
  myAttractor.ramp = attractorRamp;
  if (mousePressed && mouseButton==LEFT && !guiEvent) {
    if (!keyPressed) {
      // attraction, if left click
      myAttractor.strength = -attractorStrength; 
    } 
    else if (keyPressed && keyCode == SHIFT) {
      // repulsion, if shift + left click
      myAttractor.strength = attractorStrength; 
    }
  } 
  else {
    // otherwise no attraction or repulsion
    myAttractor.strength = 0; 
  }


  randomSeed(433);
  float r1, r2, r3, r4;
  float m = millis() / 1000.0;


  // set attractor at the mouse position
  myAttractor.x = (mouseX-width/2);
  myAttractor.y = (mouseY-height/2);
  myAttractor.z = 0;
  myAttractor.rotateX(-rotationX);
  myAttractor.rotateY(-rotationY);


  // ------ attract and update node positions ------
  float nz;
  for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
    for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
      for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
        myAttractor.attract(nodes[iz][iy][ix]);
        nodes[iz][iy][ix].update(lockX, lockY, lockZ);
      }
    }  
  }


  // ------ draw lines ------
  int stepI = 1;
  boolean lineDrawn = false;

  // x
  if (drawX && xCount > 0) {
    for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
      color c = colors[iz % colors.length];
      if (c == color(0) && invertBackground) c = color(360);
      stroke(c, lineAlpha);
      for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
        drawLine(nodes[iz][iy], xCount, drawCurves);

        if (savePDF) {
          println("saving to pdf – step " + (stepI++)); 
        }
      }
    }
    lineDrawn = true;
  } 



  // y
  if (drawY && yCount > 0) {
    for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
      color c = colors[iz % colors.length];
      if (c == color(0) && invertBackground) c = color(360);
      stroke(c, lineAlpha);
      for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
        PVector[] pts = new PVector[maxCount*2+1];
        int ii = 0;
        for (int iy = 0; iy < maxCount*2+1; iy++) {
          pts[ii++] = nodes[iz][iy][ix];
        }
        drawLine(pts, yCount, drawCurves);
        if (savePDF) {
          println("saving to pdf – step " + (stepI++)); 
        }
      }
    }
    lineDrawn = true;
  } 

  // z
  if (drawZ && zCount > 0) {
    for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
      color c = colors[iy % colors.length];
      if (c == color(0) && invertBackground) c = color(360);
      stroke(c, lineAlpha);
      for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
        PVector[] pts = new PVector[maxCount*2+1];
        int ii = 0;
        for (int iz = 0; iz < maxCount*2+1; iz++) {
          pts[ii++] = nodes[iz][iy][ix];
        }
        drawLine(pts, zCount, drawCurves);
        if (savePDF) {
          println("saving to pdf – step " + (stepI++)); 
        }
      }
    }
    lineDrawn = true;
  } 


  // if no lines were drawn, draw dots
  if (!lineDrawn) {
    if (savePDF) {
      // for pdf output, we need to draw ellipses facing to the camera
      // so we first have to transform the 3d positions to screen positions and save them in an ArrayList
      ArrayList screenPoints = new ArrayList();
      for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
        for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
          for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
            Node n = nodes[iz][iy][ix];
            screenPoints.add(new PVector(screenX(n.x, n.y, n.z), screenY(n.x, n.y, n.z), iz));
          }
        }
      }

      // then reset the transformation matrix
      popMatrix();

      // and finally draw the ellipses
      noStroke();
      for (int i = 0; i < screenPoints.size(); i++) {
        PVector sp = (PVector) screenPoints.get(i);

        color c = colors[int(sp.z) % colors.length];
        fill(red(c), green(c), blue(c), lineAlpha);

        println("saving to pdf – step " + (stepI++)); 
        ellipse(sp.x, sp.y, lineWeight, lineWeight);
      }

    }

    else{
      for (int iz = maxCount-zCount; iz <= maxCount+zCount; iz++) {
        color c = colors[iz % colors.length];
        stroke(red(c), green(c), blue(c), lineAlpha);

        for (int iy = maxCount-yCount; iy <= maxCount+yCount; iy++) {
          for (int ix = maxCount-xCount; ix <= maxCount+xCount; ix++) {
            Node n = nodes[iz][iy][ix];
            point(n.x, n.y, n.z);
          }
        }
      }
      popMatrix();
    }


  } 
  else {
    popMatrix();

  }


  // ------ draw attractor radius ------

  if (!guiEvent && mouseInWindow && !saveOneFrame && !savePDF && !tiler.checkStatus()) {
    noFill();
    strokeWeight(1);
    stroke(circleColor, 20);
    ellipse(mouseX, mouseY, myAttractor.radius*2, myAttractor.radius*2);
  }


  // ------ image output and gui ------

  // image output
  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRaw();
    println("saving to pdf – done");
  }

  if(saveOneFrame) {
    saveFrame(timestamp()+".png");
  }

  // draw gui
  if (tiler.checkStatus() == false) {
    drawGUI();
  }

  // image output
  if(saveOneFrame) {
    if (controlP5.getGroup("menu").isOpen()) {
      saveFrame(timestamp()+"_menu.png");
    }
    saveOneFrame = false;
  }

  // draw next tile for high quality output
  tiler.post();
}


void drawLine(PVector[] points, int len, boolean curves) {
  // this funktion draws a line from an array of PVectors
  // len    : number of points to each side of the center index of the array
  //          example: array-length=21, len=5 -> points[5] to points[15] will be drawn
  // curves : if true, points will be connected with curves (a bit like curveVertex, 
  //          not as accurate, but faster) 

  PVector d1 = new PVector();
  PVector d2 = new PVector();
  float l1, l2, q0, q1, q2;

  // first and last index to be drawn
  int i1 = (points.length-1) / 2 - len;
  int i2 = (points.length-1) / 2 + len;

  // draw first point
  beginShape();
  vertex(points[i1].x, points[i1].y, points[i1].z);
  q0 = 0.5;

  for (int i = i1+1; i <= i2; i++) {
    if (curves) {
      if (i < i2) {
        // distance to previous and next point
        l1 = PVector.dist(points[i], points[i-1]);
        l2 = PVector.dist(points[i], points[i+1]);
        // vector form previous to next point
        d2 = PVector.sub(points[i+1], points[i-1]);
        // shortening of this vector
        d2.mult(0.333);
        // how to distribute d2 to the anchors
        q1 = l1 / (l1+l2);
        q2 = l2 / (l1+l2);
      } 
      else {
        // special handling for the last index
        l1 = PVector.dist(points[i], points[i-1]);
        l2 = 0;
        d2.set(0, 0, 0);
        q1 = l1 / (l1+l2);
        q2 = 0;
      }
      // draw bezierVertex
      bezierVertex(points[i-1].x+d1.x*q0, points[i-1].y+d1.y*q0, points[i-1].z+d1.z*q0, 
      points[i].x-d2.x*q1, points[i].y-d2.y*q1, points[i].z-d2.z*q1,
      points[i].x, points[i].y, points[i].z);
      // remember d2 and q2 for the next iteration
      d1.set(d2);
      q0 = q2;
    } 
    else {
      vertex(points[i].x, points[i].y, points[i].z);
    }  
  }

  endShape();
}


void initGrid() {
  float xPos, yPos, zPos;
  Node n;

  for (int iz = 0; iz < maxCount*2+1; iz++) {
    for (int iy = 0; iy < maxCount*2+1; iy++) {
      for (int ix = 0; ix < maxCount*2+1; ix++) {
        xPos = (ix-maxCount)*gridStepX;
        yPos = (iy-maxCount)*gridStepY;
        zPos = (iz-maxCount)*gridStepZ;

        if (nodes[iz][iy][ix] == null) {
          n = new Node(xPos, yPos, zPos);
          n.minX = -20000;
          n.maxX = 20000;
          n.minY = -20000;
          n.maxY = 20000;
          n.minZ = -20000;
          n.maxZ = 20000;
        } 
        else {
          n = nodes[iz][iy][ix];
          n.x = xPos;
          n.y = yPos;
          n.z = zPos;
          n.velocity.x = 0;
          n.velocity.y = 0;
          n.velocity.z = 0;
        }

        n.damping = nodeDamping;

        nodes[iz][iy][ix] = n;
      }
    }
  }
}


void scaleGrid(float theFactorX, float theFactorY, float theFactorZ) {
  for (int iz = 0; iz < 9; iz++) {
    for (int iy = 0; iy < maxCount*2+1; iy++) {
      for (int ix = 0; ix < maxCount*2+1; ix++) {
        nodes[iz][iy][ix].x *= theFactorX;
        nodes[iz][iy][ix].y *= theFactorY;
        nodes[iz][iy][ix].z *= theFactorZ;
      }
    }
  }
}


void updateDamping() {
  for (int iz = 0; iz < maxCount*2+1; iz++) {
    for (int iy = 0; iy < maxCount*2+1; iy++) {
      for (int ix = 0; ix < maxCount*2+1; ix++) {
        nodes[iz][iy][ix].damping = nodeDamping;
      }
    }
  }
}


// ------ functions for reset and presets ------

void reset() {
  colors = defaultColors;
  setParas(10, 10, 10,  30, 30, 30,  150, 3, 1, 0.1, false, 1, 50, true, true, true, false, false, false, false);

  initGrid();

  targetRotationX = 0;
  targetRotationY = 0;
}


void set1() {
  colors = new color[1];
  colors[0] = color(0);

  setParas(10, 50, 10,  20, 10, 20,  400, 1, 1, 0.03, false, 6, 10, false, true, false, false, false, false, false);
  initGrid();

  targetRotationX = 0;
  targetRotationY = 0;
}

void set2() {
  colors = new color[2];
  colors[0] = color(52, 100, 71, 100);
  colors[1] = color(192, 100, 64, 100);

  setParas(20, 20, 2,  20, 10, 40,  200, 3, 1, 0.1, false, 1, 50, true, true, false, true, true, false, true);
  initGrid();
  targetRotationX = -HALF_PI;
  targetRotationY = 0;
}

void set3() {
  colors = new color[1];
  colors[0] = color(323, 100, 77);

  setParas(20, 4, 20,  4, 15, 25,  300, 8, 1, 0.1, true, 1, 50, false, true, false, true, false, true, false);
  initGrid();

  targetRotationX = 0;
  targetRotationY = -HALF_PI;
}

void set4() {
  int m = maxCount*2+1;
  colors = new color[m];
  for (int i = 0; i < m; i++) {
    float h = map(i, 0,m, 100,300);
    colors[i] = color(h, 60, 50);
  }

  setParas(10, 10, 50,  30, 30, 6,  300, 3, 1, 0.1, false, 1, 50, true, false, false, false, false, false, false);
  initGrid();

  targetRotationX = 0;
  targetRotationY = 0;
}


void setParas(int theXCount, int theYCount, int theZCount, float theGridStepX, float theGridStepY,  float theGridStepZ,
float theAttractorRadius, float theAttractorStrength, float theAttractorRamp, float theNodeDamping, 
boolean theInvertBackground, float theLineWeigth, float theLineAlpha, 
boolean theDrawX, boolean theDrawY, boolean theDrawZ,
boolean theLockX, boolean theLockY, boolean theLockZ, boolean theDrawCurves) {

  Toggle t;

  controlP5.getController("xCount").setValue(theXCount);
  controlP5.getController("yCount").setValue(theYCount);
  controlP5.getController("zCount").setValue(theZCount);
  oldXCount = theXCount;
  oldYCount = theYCount;
  oldZCount = theZCount;

  controlP5.getController("gridStepX").setValue(theGridStepX);
  controlP5.getController("gridStepY").setValue(theGridStepY);
  controlP5.getController("gridStepZ").setValue(theGridStepZ);

  controlP5.getController("attractorRadius").setValue(theAttractorRadius);
  controlP5.getController("attractorStrength").setValue(theAttractorStrength);
  controlP5.getController("attractorRamp").setValue(theAttractorRamp);
  controlP5.getController("nodeDamping").setValue(theNodeDamping);

  if (invertBackground != theInvertBackground) {
    t = (Toggle) controlP5.getController("invertBackground");
    t.setState(theInvertBackground);
  }
  controlP5.getController("lineWeight").setValue(theLineWeigth);
  controlP5.getController("lineAlpha").setValue(theLineAlpha);
  if (drawX != theDrawX) {
    t = (Toggle) controlP5.getController("drawX");
    t.setState(theDrawX);
  }
  if (drawY != theDrawY) {
    t = (Toggle) controlP5.getController("drawY");
    t.setState(theDrawY);
  }
  if (drawZ != theDrawZ) {
    t = (Toggle) controlP5.getController("drawZ");
    t.setState(theDrawZ);
  }


  if (lockX != theLockX) {
    t = (Toggle) controlP5.getController("lockX");
    t.setState(theLockX);
  }
  if (lockY != theLockY) {
    t = (Toggle) controlP5.getController("lockY");
    t.setState(theLockY);
  }
  if (lockZ != theLockZ) {
    t = (Toggle) controlP5.getController("lockZ");
    t.setState(theLockZ);
  }

  boolean theDrawLines = !theDrawCurves;
  if (drawLines != theDrawLines) {
    t = (Toggle) controlP5.getController("drawLines");
    t.setState(theDrawLines);
    drawLines = theDrawLines;
  }
  if (drawCurves != theDrawCurves) {
    t = (Toggle) controlP5.getController("drawCurves");
    t.setState(theDrawCurves);
    drawCurves = theDrawCurves;
  }    
}






void keyPressed(){

  if(key=='m' || key=='M') {
    GUI = controlP5.getGroup("menu").isOpen();
    GUI = !GUI;
  }
  if (GUI) controlP5.getGroup("menu").open();
  else controlP5.getGroup("menu").close();

  if(keyCode == LEFT) targetRotationY+=0.02;
  if(keyCode == RIGHT) targetRotationY-=0.02;
  if(keyCode == UP) targetRotationX-=0.02;
  if(keyCode == DOWN) targetRotationX+=0.02;

  if(key=='r' || key=='R') {
    // reset();
    initGrid();
    guiEvent = false;
  }
  if(key=='s' || key=='S') {
    saveOneFrame = true; 
  }
  if(key=='p' || key=='P') {
    savePDF = true; 
    saveOneFrame = true; 
    println("saving to pdf - starting (this may take some time)");
  }
  if (key =='h' || key == 'H') {
    tiler.init(timestamp()+".png", qualityFactor);
  }

  if(key==' ') {
    freeze = !freeze;
    if (freeze) noLoop();
    else loop();
  }
}




void mousePressed(){
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
}

void mouseReleased() {
  guiEvent = false;
}


void mouseEntered(MouseEvent e) {
  mouseInWindow = true;
}

void mouseExited(MouseEvent e) {
  mouseInWindow = false;
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}





















































