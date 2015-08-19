// Force_Directed_Tags.pde
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
 * generates a force directed layout with the tags found in book.xml.
 * this sketch is not explained in the book and not commented in detail
 * 
 * MOUSE
 * drag                : drag nodes
 * 
 * KEYS
 * a                   : stop/start attraction
 * arrow left/right    : node radius -/+
 * arrow down/up       : node strength -/+
 * s                   : save png
 * p                   : save pdf
 */


import generativedesign.*;
import processing.pdf.*;
import java.util.List;
import java.util.Collections;
import java.util.Iterator;
import java.util.Calendar;

boolean savePDF = false;

// initial parameters
int qf = 3;

boolean drawSprings = true;
color springColor = color(0, 255);
color[] springColors = {
  color(0), color(226,185,0), color(0,143,193)};

boolean drawNodes1 = true;
float nodeDiameter1 = 0.6;
boolean drawNodes2 = true;
float nodeDiameter2 = 1;

float nodeRadius = 70;
float nodeStrength = -5;

boolean drawPageLayout = false;
color pageColor = color(0, 80);
boolean drawBlankImages = true;
boolean drawText = true;

boolean attractionOn = true;

// images
int imageCount;

// pages
int imagesPerLine = 16;
float gridMarginLeft = 9 * qf;
float gridMarginTop = 10.5 * qf;
float gridStepX = 24.314 * qf;
float gridStepY = 19.185 * qf;
float gridImageW = 18.8 * qf;
float gridImageH = 13.1 * qf;
float gridFoldW = 14 * qf;


// an array for the nodes
Node[] nodes = new Node[0];
// an array for the springs
Spring[] springs = new Spring[0];

// dragged node
Node selectedNode = null;

// tagging
XML bookXML;
HashMap tagMap = new HashMap();
List sortedTags;
ArrayList[] pageTags = new ArrayList[0];
ArrayList[] pageTagPositions = new ArrayList[0];
int pageSum = 0;
int[] bookParts = new int[0];

PFont font;


void setup() {
  size((2*205)*qf, 285*qf); 
  background(255);
  smooth();
  noStroke();

  font = createFont("FreeSansBold.ttf",12);
  textFont(font, 7*qf);

  // ------ load and interpret xml ------ 

  try {
    bookXML = loadXML("book.xml");
  } catch (Exception e) {
  }
  
  int numEntries = bookXML.getChildCount();
  int tagSum = 0;
  XML[] sections = bookXML.getChildren("sections/section");
  for (int i=0; i < sections.length; i++) {
    int pageCount = sections[i].getInt("pagecount"); 
    String pageName = sections[i].getString("name");
    int bookpart = sections[i].getInt("part"); 

    if (bookpart > 0) {
      bookParts = append(bookParts, pageSum);
    }

    pageSum += pageCount;

    XML[] tags = sections[i].getChildren("tag");

    ArrayList tagList = new ArrayList();
    ArrayList inTagBlockPosition = new ArrayList();

    for (int j=0; j < tags.length; j++) {
      String tagName = tags[j].getString("name");
      String tagNameUpperCase = tagName;

      Tag tag = (Tag) tagMap.get(tagNameUpperCase);
      if (tag == null) {
        tag = new Tag(tagName);
        tagMap.put(tagNameUpperCase, tag);
      }
      tag.count += pageCount;
      tagSum += pageCount;

      tagList.add(tag);
      inTagBlockPosition.add(tag.count-pageCount);
    }

    // append array which holds all tags for each page
    for (int k=0; k < pageCount; k++) {
      pageTags = (ArrayList[]) append(pageTags, tagList);

      // println(inTagBlockPosition);
      pageTagPositions = (ArrayList[]) append(pageTagPositions, inTagBlockPosition.clone());

      for (int j=0; j < tags.length; j++) {
        int c = (Integer) inTagBlockPosition.get(j);
        c++;
        inTagBlockPosition.set(j, c);
      }
    }
  }

  sortedTags = new ArrayList();
  sortedTags.addAll(tagMap.keySet());
  Collections.sort(sortedTags);

  imageCount = pageSum;

  // ------ init nodes and springs ------

  // init nodes
  for (int i = 0; i < pageSum; i++) {
    int ix = i % imagesPerLine;
    int iy = floor(i / (float)imagesPerLine);
    float px = gridMarginLeft + ix*gridStepX + +gridImageW/2;
    if (ix >= imagesPerLine/2) px += (gridFoldW-(gridStepX-gridImageW));
    float py = gridMarginTop + iy*gridStepY + +gridImageH/2;
    Node n = new Node(px, py);
    nodes = (Node[]) append(nodes, n);
    nodes[i].setBoundary(px, py, px, py);
    nodes[i].setRadius(50);
    nodes[i].setStrength(-5);
    nodes[i].setID(str(i));
  } 
  for (int i = 0; i < sortedTags.size(); i++) {
    //println(sortedTags.get(i));
    Node n = new Node(width/2+random(-200, 200), height/2+random(-200, 200));
    nodes = (Node[]) append(nodes, n);
    nodes[pageSum+i].setBoundary(0, 0, width, height);
    nodes[pageSum+i].setRadius(nodeRadius*qf);
    nodes[pageSum+i].setStrength(nodeStrength);
    nodes[pageSum+i].setID(sortedTags.get(i).toString());
  } 

  // set springs
  springs = new Spring[0];

  for (int j = 0 ; j < pageTags.length; j++) {
    for (int i = 0; i < pageTags[j].size(); i++) {
      Tag t = (Tag) pageTags[j].get(i);
      int tagIndex = getTagIndexByName(t.name);
      //println(t.name + ", " + tagIndex);
      if (tagIndex >= 0) {
        Spring newSpring = new Spring(nodes[j], nodes[pageTags.length+tagIndex]);
        newSpring.setLength(20);
        newSpring.setStiffness(1);
        springs = (Spring[]) append(springs, newSpring);
      }
    }
  }

}


void draw() {
  if (savePDF) beginRecord(PDF, timestamp()+".pdf");

  background(255);

  if (attractionOn) {
    // let all nodes repel each other
    for (int i = pageSum; i < nodes.length; i++) {
      nodes[i].attract(nodes);
    } 
    // apply spring forces
    for (int i = 0 ; i < springs.length; i++) {
      springs[i].update();
    } 
    // apply velocity vector and update position
    for (int i = pageSum ; i < nodes.length; i++) {
      nodes[i].update();
    } 
  }

  if (selectedNode != null) {
    selectedNode.x = mouseX;
    selectedNode.y = mouseY;
  }


  if (drawPageLayout) {
    noFill();
    stroke(0, 150);
    strokeWeight(0.15*qf);

    for (int i = 1; i < 6; i++) {
      line(i*345*qf, 0, i*345*qf, height); 
    }
  }

  if (drawBlankImages) {
    fill(255);
    stroke(pageColor);
    strokeWeight(0.15*qf);

    for (int i = 0; i < imageCount; i++) {
      //if (laodimages) img = images[i];
      int ix = i % imagesPerLine;
      int iy = floor(i / (float)imagesPerLine);
      float px = gridMarginLeft + ix*gridStepX;
      if (ix >= imagesPerLine/2) px += (gridFoldW-(gridStepX-gridImageW));
      float py = gridMarginTop + iy*gridStepY;
      rect(px, py, gridImageW, gridImageH);
      line(px+gridImageW/2, py, px+gridImageW/2, py+gridImageH); 
    }
  }


  // draw springs
  if (drawSprings) {
    strokeWeight(0.1*qf);
    noFill();
    int actBookPart = 0;
    for (int i = 0 ; i < springs.length; i++) {
      if (actBookPart+1 < bookParts.length) {
        if (int(springs[i].fromNode.id) >= bookParts[actBookPart+1]) actBookPart++; 
      }
      stroke(springColors[actBookPart]);
      float x1 = springs[i].fromNode.x + springs[i].fromNode.z;
      float y1 = springs[i].fromNode.y;
      float x2 = springs[i].toNode.x + springs[i].toNode.z;
      float y2 = springs[i].toNode.y;
      float cxoff = -50*qf;
      if (x2 < width/2) cxoff = +50*qf;

      line(x1, y1, x2, y2);
    }
  }

  // draw nodes
  noStroke();
  int actBookPart = 0;
  for (int i = 0 ; i < nodes.length; i++) {
    if (actBookPart+1 < bookParts.length) {
      if (int(nodes[i].id) >= bookParts[actBookPart+1]) actBookPart++; 
    }

    float nodeDiameter = nodeDiameter1*qf;
    if (i >= pageSum) {
      Tag tag = (Tag) tagMap.get(nodes[i].id);
      float s = map(tag.count, 1,50, 2.5,15) / 4;
      nodeDiameter = nodeDiameter2*qf * s;
    }

    if (drawNodes1 && i<pageSum) {
      fill(springColors[actBookPart]);
      ellipse(nodes[i].x+nodes[i].z, nodes[i].y, nodeDiameter1*qf, nodeDiameter1*qf);
    }

    if (drawNodes2 && i>=pageSum) {
      fill(255);
      ellipse(nodes[i].x+nodes[i].z, nodes[i].y, nodeDiameter, nodeDiameter);
      fill(0);
      ellipse(nodes[i].x+nodes[i].z, nodes[i].y, nodeDiameter*0.7, nodeDiameter*0.7);
    }
  }

  if (drawText) {
    fill(0);
    for (int i = pageSum ; i < nodes.length; i++) {
      Tag tag = (Tag) tagMap.get(nodes[i].id);
      float s = map(tag.count, 1,50, 2.5,15);

      textFont(font, s*qf);
      if (nodes[i].x+nodes[i].z > width/2) {
        textAlign(LEFT, CENTER);
        text(nodes[i].id, nodes[i].x+nodes[i].z+(s*0.1+1)*qf, nodes[i].y);
      } 
      else {
        textAlign(RIGHT, CENTER);
        text(nodes[i].id, nodes[i].x+nodes[i].z-(s*0.1+1)*qf, nodes[i].y);
      }

    }
  }

  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}


int getTagIndexByName(String name) {
  for (int i = 0 ; i < sortedTags.size(); i++) {
    String s1 = name.toUpperCase();
    String s2 = sortedTags.get(i).toString().toUpperCase();
    if (s1.equals(s2)) {
      return i;      
    }
  } 
  return -1;
}



void mousePressed() {
  // Ignore anything greater than this distance
  float maxDist = 20;
  for (int i = pageSum; i < nodes.length; i++) {
    Node checkNode = nodes[i];
    float d = dist(mouseX, mouseY, checkNode.x, checkNode.y);
    if (d < maxDist) {
      selectedNode = checkNode;
      maxDist = d;
    }
  }
}

void mouseReleased() {
  if (selectedNode != null) {
    selectedNode = null;
  }
}


void keyPressed() {
  if(key=='s' || key=='S') saveFrame(timestamp()+"_##.png"); 

  if(key=='p' || key=='P') {
    savePDF = true; 
    println("saving to pdf - starting (this may take some time)");
  }

  if(key=='a' || key=='A') attractionOn = !attractionOn; 

  if (keyCode == LEFT) nodeRadius /= 1.5;
  if (keyCode == RIGHT) nodeRadius *= 1.5;
  if (keyCode == DOWN) nodeStrength /= 1.5;
  if (keyCode == UP) nodeStrength *= 1.5;
  println("nodeRadius: " + nodeRadius + ", " + "nodeStrength: " + nodeStrength);

  for (int i = 0; i < sortedTags.size(); i++) {
    nodes[pageSum+i].setRadius(nodeRadius*qf);
    nodes[pageSum+i].setStrength(nodeStrength);
  } 

}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}














































