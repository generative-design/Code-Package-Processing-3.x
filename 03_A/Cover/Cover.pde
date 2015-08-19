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
 * sketch, generating the cover of the book "Generative Gestaltung"
 * and automatically saving it as a png.
 * attention: this will take some time to render
 */


import generativedesign.*;
import geomerative.*;
import processing.pdf.*;
import java.util.List;
import java.util.Collections;
import java.util.Iterator;
import java.util.Calendar;
import java.io.File;


// initial parameters
int qf = 1;  //// quality factor: 5 for print resolution
int qffinal = 5;
int stripResolution = 40;
int stripCount = 20;

float blockFactor = 0.56;
int blockOffsetX = 580 * qf;
float blockOffsetY = 306 * qf;
float tagBlockWidth = 207 * qf;
boolean onBlack = false;
int stripDir = 0;
boolean stripDirAlternating = false;

boolean reversed = false;
int sortRibbonsOnStartXPos = 620 * qf;
int sortRibbonsOnStartYPos = 630 * qf;

// typo points
String[] typedTexts = {
  "GENERATIVE", "GESTALTUNG", "Entwerfen\nProgrammieren", "Visualisieren", "Hartmut Bohnacker\nBenedikt Groß\nJulia Laub\nClaudius Lazzeroni (Hrsg.)", "Verlag Hermann\nSchmidt Mainz", "............................."
};
String[] fontNames = {
  "FreeSansBold.ttf", "FreeSansBold.ttf", "FreeSansBold.ttf", "FreeSansBold.ttf", "FreeSansBold.ttf", "FreeSansBold.ttf", "FreeSansBold.ttf"
};
int[] fontSizes = {
  72, 72, 25, 25, 14, 20, 14, 12
};
float[] lineSpacings = {
  0.9, 0.9, 1.1, 1.1, 1.2, 1.2, 1
};
float[] typoSegmentLengths = {
  3.5, 3.5, 3.5, 3.5, 3.5, 3.5, 3.5
};
float[] textPosXs = {
  205, 205, 448.5, 449.5, 261, 505, 505
};
float[] textPosYs = {
  188, 256, 313, 370, 424, 730, 752
};
float[] textScaleXs = {
  1, 1, 1, 1, 1, 1, 1
};
float[] textAngles = {
  0, 0, 0, 0, 0, 0, 0
};
float[] textNormalsFactor = {
  1.5, 1.5, 0.75, 0.75, 0.75, 0.75, 0.75
};

float stripDistributionPotenz = 1.27;

float perspCenterX = 630 * qf;
float perspCenterY = 630 * qf;


float letterY = 0;
RFont font;
RGroup grp;
RPoint[] pnts;
RPoint[] typoPoints = new RPoint[0];
int[] typoNextIndex = new int[0];
int[] typoPrevIndex = new int[0];
PVector[] typoNormals = new PVector[0];
PVector[] typoTangents = new PVector[0];
Node[] typoNodes = new Node[0];
int[] textIndexStarts = new int[0];


// images
PImage img;
PImage[] images;
int imageCount;


// ribbons
ImageRibbon[] ribbons;

// attractors
Attractor[] myAttractors = new Attractor[2];


// tagging
PFont tagFont;
XML bookXML;
HashMap tagMap = new HashMap();
List sortedTags;
XML[] pageXMLs = new XML[0];
int[] pageInSection = new int[0];
ArrayList[] pageTags = new ArrayList[0];
ArrayList[] pageTagPositions = new ArrayList[0];
float tagBlockFactor = 1;
float tagBlockGapRatio = 0.25;




void setup() {
  size(1310*qf, 822*qf); 
  frameRate(4);

  smooth();

  tagFont = createFont("FreeSansBold.ttf", 10);


  // ------ init text points ------

  RG.init(this);

  for (int ti = 0; ti < typedTexts.length; ti++) {

    String typedText = typedTexts[ti];
    String fontName = fontNames[ti];
    int fontSize = fontSizes[ti]*qffinal;
    float lineSpacing = fontSizes[ti]*qf * lineSpacings[ti];
    float typoSegmentLength = typoSegmentLengths[ti]*qffinal;
    float textPosX = textPosXs[ti]*qf;
    float textPosY = textPosYs[ti]*qf;
    float textScaleX = textScaleXs[ti];
    float textAngle = radians(textAngles[ti]);

    font = new RFont(fontName, fontSize, RFont.LEFT);
    RCommand.setSegmentLength(typoSegmentLength);
    RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

    textIndexStarts = append(textIndexStarts, typoNodes.length);

    int firstIndex = 0;
    String texts[] = split(typedText, '\n');
    for (int i = 0 ; i < texts.length; i++) {
      grp = font.toGroup(texts[i]);
      pnts = grp.getPoints(); 

      PVector oldPnt = null;
      PVector actPnt = null;

      for (int p = 0; p < pnts.length; p++) {
        pnts[p].x = pnts[p].x / qffinal * qf;
        pnts[p].y = pnts[p].y / qffinal * qf;

        if (actPnt == null) actPnt = new PVector(pnts[p].x, pnts[p].y);
        if (oldPnt == null) oldPnt = new PVector(pnts[p].x, pnts[p].y);

        // find out, if a new closed shape begins
        actPnt = new PVector(pnts[p].x, pnts[p].y);

        if (p == pnts.length-1) {
          typoNextIndex = (int[]) append(typoNextIndex, firstIndex);
          firstIndex = typoNextIndex.length;
        }
        else if (dist(actPnt.x, actPnt.y, oldPnt.x, oldPnt.y) > typoSegmentLength + 1) {
          typoNextIndex[typoNextIndex.length-1] = firstIndex;
          firstIndex = typoNextIndex.length;
          typoNextIndex = (int[]) append(typoNextIndex, typoNextIndex.length+1);
        } 
        else {
          typoNextIndex = (int[]) append(typoNextIndex, typoNextIndex.length+1);
        }
        oldPnt = new PVector(pnts[p].x, pnts[p].y);

        // move typo point to final position and append array
        float px =  pnts[p].x * textScaleX;
        float py =  pnts[p].y + letterY;
        pnts[p].x = px * cos(textAngle) - py * sin(textAngle) + textPosX;
        pnts[p].y = px * sin(textAngle) + py * cos(textAngle) + textPosY;
        typoPoints = (RPoint[]) append(typoPoints, pnts[p]); 

        Node n = new Node(pnts[p].x, pnts[p].y);
        //n.id = "fixed";
        n.radius = 100;
        n.strength = -1;
        n.ramp = 1;
        typoNodes = (Node[]) append(typoNodes, n);
      }
      letterY += lineSpacing;
    }
    letterY = 0;
  }

  typoPrevIndex = new int[typoNextIndex.length];
  for (int i = 0 ; i < typoNextIndex.length; i++) {
    typoPrevIndex[typoNextIndex[i]] = i;
  }

  // calculate normals for typo points
  for (int i = 0 ; i < typoPoints.length; i++) {
    PVector tangent = new PVector();
    tangent.x = (typoPoints[typoPrevIndex[i]].x - typoPoints[typoNextIndex[i]].x);
    tangent.y = (typoPoints[typoPrevIndex[i]].y - typoPoints[typoNextIndex[i]].y);
    tangent.normalize();
    typoTangents = (PVector[]) append(typoTangents, tangent);
    typoNormals = (PVector[]) append(typoNormals, new PVector(-tangent.y, tangent.x));
  }

  //println(textIndexStarts);
  //println(partEnd);
  //println(typoNodes.length);


  // ------ load and interpret xml ------ 

  try {
    bookXML = loadXML("data/book.xml");
  } 
  catch (Exception e) {
    println(e);
  }

  int pageSum = 0;
  int tagSum = 0;
  XML[] sections = bookXML.getChildren("sections/section");

  for (int i=0; i < sections.length; i++) {
    int pageCount = sections[i].getInt("pagecount"); 
    String pageName = sections[i].getString("name");
    pageSum += pageCount;

    XML[] tags = sections[i].getChildren("tag");

    ArrayList tagList = new ArrayList();
    ArrayList inTagBlockPosition = new ArrayList();

    for (int j=0; j < tags.length; j++) {
      String tagName = tags[j].getString("name");
      String tagNameUpperCase = tagName.toUpperCase();

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
      pageInSection = (int[]) append(pageInSection, k);
      pageXMLs = (XML[]) append(pageXMLs, sections[i]);

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

  // distribute tag block ratio and positions
  float actPos = 0;
  for (int i = 0 ; i < sortedTags.size(); i++) {
    String tagName = (String) sortedTags.get(i);
    Tag tag = (Tag) tagMap.get(tagName);
    tag.ratio = float(tag.count)/tagSum;
    tag.position = actPos;
    tag.orderNum = i;
    actPos += tag.ratio;
  }


  // ------ load files ------
  imageCount = 0;

  File dir = new File(sketchPath, "data/images");

  if (dir.isDirectory()) {
    String[] contents = dir.list();
    images = new PImage[contents.length]; 
    //for (int i = 15 ; i < 60; i++) {
    for (int i = 0 ; i < contents.length; i++) {
      if (contents[i].charAt(0) == '.') continue;
      else if (contents[i].toLowerCase().endsWith(".png") || contents[i].toLowerCase().endsWith(".jpg")) {
        File childFile = new File(dir, contents[i]);        
        images[imageCount] = loadImage(childFile.getPath());
        println(imageCount+" - "+contents[i]);
        imageCount++;
      }
    }
  }


  // ------ setup ribbons ------
  ribbons = new ImageRibbon[imageCount*stripCount];
  int ii = 0;
  int actTextIndex = 0;
  noiseSeed(2);

  for (int i = 0; i < imageCount; i++) {
    for (int s = 0; s < stripCount; s++) {
      img = images[i];
      int w = img.width;
      int h = img.height / stripCount;
      int y = int(s * img.height / float(stripCount));
      PImage strip = img.get(0, y, w, h);

      float pi = map(i*stripCount+s, 0, imageCount*stripCount, 0, 1);
      pi = pow(pi, stripDistributionPotenz);
      int pIndex = int(map(pi, 0, 1, 1, typoPoints.length-1));
      pIndex = pIndex % (typoPoints.length-1) + 1;
      if (reversed) pIndex = typoPoints.length-1 - pIndex;

      if (actTextIndex < textIndexStarts.length-1) {
        if (pIndex >= textIndexStarts[actTextIndex+1]) {
          actTextIndex++;
        }
      }

      // get position from tag information
      int tagIndex = s % pageTags[i].size();
      Tag stripTag = (Tag) pageTags[i].get(tagIndex);
      float stripTagPosition = (Integer) pageTagPositions[i].get(tagIndex);
      stripTagPosition /= float(stripTag.count);
      float tagPosY = (stripTag.position + stripTagPosition*stripTag.ratio*tagBlockFactor) * (1-tagBlockGapRatio) + stripTag.orderNum*(1.0/sortedTags.size()) * tagBlockGapRatio;
      float tagX = -tagBlockWidth;
      float tagY = tagPosY * height * blockFactor + blockOffsetY;

      float midX = 0;
      float midY = (i+float(s)/stripCount) * (float)height/imageCount * blockFactor + blockOffsetY;

      float typoX = typoPoints[pIndex].x - typoNormals[pIndex].x*textNormalsFactor[actTextIndex]*qf;
      float typoY = typoPoints[pIndex].y - typoNormals[pIndex].y*textNormalsFactor[actTextIndex]*qf;


      PVector[] pnts = new PVector[stripResolution];
      for (int p = 0; p < pnts.length; p++) {
        float t = map(p, 0, pnts.length-1, 0, 1);
        float posX = 0;
        float posY = 0;

        if (t >= 0 && t <= 0.5) {
          float tt = map(t, 0, 0.5, 0, 1);
          posX = bezierPoint(tagX, tagX+tagBlockWidth*0.75, midX-tagBlockWidth*0.75, midX, tt);
          posY = bezierPoint(tagY, tagY, midY, midY, tt);
        } 
        else {
          float tt = map(t, 0.5, 1, 0, 1);
          float offx = -(typoX - perspCenterX);
          float offy = -(typoY - perspCenterY);
          posX = bezierPoint(midX, midX+200*qf, typoX+offx, typoX, tt);
          posY = bezierPoint(midY, midY, typoY+offy, typoY, tt);
        }

        pnts[p] = new PVector(posX, posY);
      }     

      pnts = (PVector[]) reverse(pnts);
      ribbons[i*stripCount+s] = new ImageRibbon(this, pnts, strip, pageXMLs[i], pageInSection[i], s);
      ribbons[i*stripCount+s].direction = stripDir;
      if (stripDirAlternating) stripDir *= -1;
      ii++;
    }
  }

  sortRibbonsOnStartDistTo(sortRibbonsOnStartXPos, sortRibbonsOnStartYPos);
}


void draw() {
  background(255);

  translate(blockOffsetX, 0);

  randomSeed(0);


  // write tags
  pushStyle();
  textAlign(RIGHT, TOP);
  for (int i = 0; i < sortedTags.size(); i++) {
    String tagName = (String) sortedTags.get(i);
    Tag tag = (Tag) tagMap.get(tagName);

    float px = -tagBlockWidth - 8*qf;
    float py = tag.position * (1-tagBlockGapRatio) + tag.orderNum*(1.0/sortedTags.size()) * tagBlockGapRatio;
    py = py * height * blockFactor + blockOffsetY;

    noStroke();
    fill(0);
    float blockHeight = tag.ratio * height * blockFactor * tagBlockFactor * (1-tagBlockGapRatio);
    textFont(tagFont, max(blockHeight*1, 3.5*qf));
    text(tag.name, px-0*qf, py-blockHeight*0.2);
  }
  popStyle();


  // draw ribbons
  for (int i = 0; i < ribbons.length; i++) {
    println(i + " / " + ribbons.length);
    ribbons[i].draw();
  }


  // draw white typo
  noStroke();
  fill(255);

  for (int ti = 0; ti < typedTexts.length; ti++) {

    String typedText = typedTexts[ti];
    String fontName = fontNames[ti];
    int fontSize = fontSizes[ti]*qf;
    float lineSpacing = fontSize * lineSpacings[ti];
    float textPosX = textPosXs[ti]*qf;
    float textPosY = textPosYs[ti]*qf;
    float textAngle = radians(textAngles[ti]);

    PFont f = createFont(fontName, fontSize-1);
    textFont(f);

    String texts[] = split(typedText, '\n');
    letterY = 0;
    pushMatrix();
    translate(textPosX, textPosY);
    rotate(textAngle);
    for (int i = 0 ; i < texts.length; i++) {
      text(texts[i], 0, letterY);
      letterY += lineSpacing;
    }
    popMatrix();
    letterY = 0;
  }


  // automatically save png
  saveFrame(timestamp()+".png");

  println("finished");
  noLoop();

  //saveFrame(timestamp()+"_##.png");
}



void sortRibbonsOnStartX(int dir) {
  if (dir != 0) {
    for (int j = 0; j < ribbons.length-1; j++) {
      for (int i = j; i < ribbons.length; i++) {
        if (dir*ribbons[j].nodes[0].x < dir*ribbons[i].nodes[0].x) {
          ImageRibbon rj = ribbons[j];
          ImageRibbon ri = ribbons[i];
          ribbons[j] = new ImageRibbon();
          ribbons[j] = ri;
          ribbons[i] = new ImageRibbon();
          ribbons[i] = rj;
        }
      }
    }
  }
}

void sortRibbonsOnStartY(int dir) {
  if (dir != 0) {
    for (int j = 0; j < ribbons.length-1; j++) {
      for (int i = j; i < ribbons.length; i++) {
        if (dir*ribbons[j].nodes[0].y < dir*ribbons[i].nodes[0].y) {
          ImageRibbon rj = ribbons[j];
          ImageRibbon ri = ribbons[i];
          ribbons[j] = new ImageRibbon();
          ribbons[j] = ri;
          ribbons[i] = new ImageRibbon();
          ribbons[i] = rj;
        }
      }
    }
  }
}

void sortRibbonsOnStartYPos(float pos) {
  for (int j = 0; j < ribbons.length-1; j++) {
    for (int i = j; i < ribbons.length; i++) {
      if (abs(ribbons[j].nodes[0].y-pos) < abs(ribbons[i].nodes[0].y-pos)) {
        ImageRibbon rj = ribbons[j];
        ImageRibbon ri = ribbons[i];
        ribbons[j] = new ImageRibbon();
        ribbons[j] = ri;
        ribbons[i] = new ImageRibbon();
        ribbons[i] = rj;
      }
    }
  }
}

void sortRibbonsOnStartDistTo(float posX, float posY) {
  for (int j = 0; j < ribbons.length-1; j++) {
    for (int i = j; i < ribbons.length; i++) {
      if (dist(ribbons[j].nodes[0].x, ribbons[j].nodes[0].y*5, posX, posY*5) < dist(ribbons[i].nodes[0].x, ribbons[i].nodes[0].y*5, posX, posY*5)) {
        ImageRibbon rj = ribbons[j];
        ImageRibbon ri = ribbons[i];
        ribbons[j] = new ImageRibbon();
        ribbons[j] = ri;
        ribbons[i] = new ImageRibbon();
        ribbons[i] = rj;
      }
    }
  }
}


void sortRibbonsOnEndX(int dir) {
  if (dir != 0) {
    for (int j = 0; j < ribbons.length-1; j++) {
      for (int i = j; i < ribbons.length; i++) {
        if (dir*ribbons[j].nodes[ribbons[j].count-1].x < dir*ribbons[i].nodes[ribbons[i].count-1].x) {
          ImageRibbon rj = ribbons[j];
          ImageRibbon ri = ribbons[i];
          ribbons[j] = new ImageRibbon();
          ribbons[j] = ri;
          ribbons[i] = new ImageRibbon();
          ribbons[i] = rj;
        }
      }
    }
  }
}

void sortRibbonsOnEndY(int dir) {
  if (dir != 0) {
    for (int j = 0; j < ribbons.length-1; j++) {
      for (int i = j; i < ribbons.length; i++) {
        if (dir*ribbons[j].nodes[ribbons[j].count-1].y < dir*ribbons[i].nodes[ribbons[i].count-1].y) {
          ImageRibbon rj = ribbons[j];
          ImageRibbon ri = ribbons[i];
          ribbons[j] = new ImageRibbon();
          ribbons[j] = ri;
          ribbons[i] = new ImageRibbon();
          ribbons[i] = rj;
        }
      }
    }
  }
}

void sortRibbonsOnEndYPos(float pos) {
  for (int j = 0; j < ribbons.length-1; j++) {
    for (int i = j; i < ribbons.length; i++) {
      if (abs(ribbons[j].nodes[ribbons[j].count-1].y-pos) < abs(ribbons[i].nodes[ribbons[i].count-1].y-pos)) {
        ImageRibbon rj = ribbons[j];
        ImageRibbon ri = ribbons[i];
        ribbons[j] = new ImageRibbon();
        ribbons[j] = ri;
        ribbons[i] = new ImageRibbon();
        ribbons[i] = rj;
      }
    }
  }
}

float hillCurve(float t, int parts) {
  float res = 1;
  if (t < 1.0/parts) res = -cos(t*PI*parts)*0.5+0.5;
  if (t > 1-1.0/parts) res = -cos((t-1)*PI*parts)*0.5+0.5;
  return res;
}



String intArrayToString(int[] arr) {
  String s = "";
  for (int i = 0; i < arr.length; i++) {
    s = s + str(arr[i]) + ", ";
  }
  return s;
}

String floatArrayToString(float[] arr) {
  String s = "";
  for (int i = 0; i < arr.length; i++) {
    s = s + str(arr[i]) + ", ";
  }
  return s;
}

String arrayToString(Object[] arr) {
  String s = "";
  for (int i = 0; i < arr.length; i++) {
    s = s + arr[i].toString() + ", ";
  }
  return s;
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}




















































