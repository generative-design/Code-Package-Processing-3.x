// M_6_4_01_TOOL.pde
// GUI.pde, WikipediaGraph.pde, WikipediaNode.pde
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
 * exploring wikipedia
 *
 * MOUSE
 * left click          : show links for the clicked node
 * double left click   : create node
 * shift + left click  : remove node
 * alt + left click    : show backlinks for the clicked node
 * right click + drag  : drag canvas or node
 * double right click  : open article in browser
 *
 * KEYS
 * 1                   : toggle colorize nodes
 * 2                   : toggle fish eye view
 * arrow up/down       : zoom
 * m                   : menu open/close
 * s                   : save png
 * p                   : save pdf
 */


// ------ imports ------

import generativedesign.*;
import processing.data.XML;
import processing.pdf.*;
import java.net.*;
import java.io.UnsupportedEncodingException;
import java.util.regex.*;
import java.util.Calendar;
import java.util.Iterator;
import java.util.Map;


// ------ initial parameters and declarations ------
PApplet root = this;

// start with this keyword
String actKeyword = "Design";
WikipediaNode actNode;

float zoom = 0.75;
boolean autoZoom = false;

int resultCount = 10;

float springLength = 100;
float springStiffness = 0.4;
float springDamping = 0.9;

float nodeRadius = 200;
float nodeStrength = 15;
float nodeDamping = 0.5;

boolean invertBackground = false;
boolean drawFishEyed = false;
float lineWeight = 1;
float lineAlpha = 100;
float linkColor = 0.89;

boolean colorizeNodes = true;
float minNodeDiameter = 8;
float nodeDiameterFactor = 20;
float nodeColor = 1;

boolean showText = true;
boolean showRolloverText = true;
boolean showRolloverNeighbours = false;

PApplet thisPApplet = this;

// the graph
WikipediaGraph myWikipediaGraph;



// ------ mouse interaction ------

boolean dragging = false;
float offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, clickOffsetX = 0, clickOffsetY = 0;
int lastMouseButton = 0;


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



void setup(){
  size(800, 800);
  //textMode(SHAPE);
  setupGUI();
  guiEvent = false;

  smooth();
  noStroke();

  // make window resizable
  surface.setResizable(true);

  // construct a new WikipediaGraph
  myWikipediaGraph = new WikipediaGraph();

  // add the first node to the graph
  actNode = (WikipediaNode) myWikipediaGraph.addNode(actKeyword, 0, 0);
  actNode.wasClicked = true;
}


void draw() {
  if (savePDF) {
    beginRecord(PDF, timestamp()+".pdf");
    myWikipediaGraph.freezeTime = true;
  }


  // ------ white/black background ------

  color bgColor = color(255);
  if (invertBackground) {
    bgColor = color(0);
  } 
  background(bgColor);


  // ------ update zooming and position of graph ------
  myWikipediaGraph.autoZoom = autoZoom;
  if (autoZoom) {
    boolean tmpGuiEvent = guiEvent;
    controlP5.getController("zoom").setValue(myWikipediaGraph.getZoom());
    guiEvent = tmpGuiEvent;
  }
  else{
    myWikipediaGraph.setZoom(zoom);
    // canvas dragging
    if (dragging) {
      myWikipediaGraph.setOffset(clickOffsetX + (mouseX - clickX), clickOffsetY + (mouseY - clickY));
    }
  }

  // ------ update and draw graph ------
  myWikipediaGraph.setResultCount(resultCount);

  myWikipediaGraph.setSpringLength(springLength);
  myWikipediaGraph.setSpringStiffness(springStiffness);
  myWikipediaGraph.setSpringDamping(springDamping);

  myWikipediaGraph.setNodeRadius(nodeRadius);
  myWikipediaGraph.setNodeStrength(-nodeStrength);
  myWikipediaGraph.setNodeDamping(nodeDamping);

  myWikipediaGraph.setInvertBackground(invertBackground);
  myWikipediaGraph.setDrawHyperbolic(drawFishEyed);

  myWikipediaGraph.setLineWeight(lineWeight);
  myWikipediaGraph.setLineAlpha(lineAlpha);
  myWikipediaGraph.setLinkColor(linearColor(linkColor));

  myWikipediaGraph.setMinNodeDiameter(minNodeDiameter);
  myWikipediaGraph.setNodeDiameterFactor(nodeDiameterFactor);
  myWikipediaGraph.setColorizeNodes(colorizeNodes);

  myWikipediaGraph.setShowText(showText);
  myWikipediaGraph.setShowRolloverText(showRolloverText);
  myWikipediaGraph.setShowRolloverNeighbours(showRolloverNeighbours);


  myWikipediaGraph.update();
  myWikipediaGraph.draw();


  // ------ image output ------
  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
    println("saving to pdf – done");
    myWikipediaGraph.freezeTime = false;
  }

  if(saveOneFrame == true) {
    saveFrame(timestamp()+".png");
    saveOneFrame = false;
  }

  // draw gui
  drawGUI();

}



// function encodeURL based on a post on the processing discourse pages
// posted by PhiLho on May 28th, 2008
//
// converts special chars in a string to be suitable for a url
String encodeURL(String url) {

  // Use URI to encode low Ascii characters depending on context of various parts
  // For some reason, uri = new URI(url) chokes on space, so we have to split the URL
  String scheme = null;  // http, ftp, etc.
  String ssp = null; // scheme-specific part
  String fragment = null; // #anchor for example
  int colonPos = url.indexOf(":");
  if (colonPos < 0) return "Not an URL";
  scheme = url.substring(0, colonPos);
  ssp = url.substring(colonPos + 1);
  int fragPos = ssp.lastIndexOf("#");
  if (fragPos >= 0) {
    // Won't work if there is no real anchor/fragment
    // but this char is part of one parameter of the query,
    // but it is a bit unlikely...
    // That's probably why Java doesn't want to do it automatically,
    // it must be disambiguated manually
    fragment = ssp.substring(fragPos + 1);
    ssp = ssp.substring(0, fragPos);
  }

  URI uri = null;
  try {
    uri = new URI(scheme, ssp, fragment);
  } 
  catch (URISyntaxException use) { 
    return use.toString(); 
  }
  String encodedURL1 = null;
  try {
    encodedURL1 = uri.toURL().toString();
  } 
  catch (MalformedURLException mue) { 
    return mue.toString(); 
  }
  // Here, we still have Unicode chars unchanged

  byte[] utf8 = null;
  // Convert whole string to UTF-8 at once: low Ascii (below 0x80) is unchanged, other stuff is converted
  // to UTF-8, which always have the high bit set.
  try {
    utf8 = encodedURL1.getBytes("UTF-8");
  } 
  catch (UnsupportedEncodingException uee) { 
    return uee.toString(); 
  }

  StringBuffer encodedURL = new StringBuffer();

  byte[] conv = new byte[1];
  for (int i = 0; i < utf8.length; i++) {
    // Beyond Ascii: high bit is set, hence negative byte
    if (utf8[i] < 0) {
      encodedURL.append("%" + Integer.toString(256 + (int)utf8[i], 16));
    }
    else {
      conv[0] = utf8[i];
      try {
        encodedURL.append(new String(conv, "ASCII")); // Convert back to Ascii
      } 
      catch (UnsupportedEncodingException uee) { 
        return uee.toString(); 
      }
    }
  }

  return encodedURL.toString();
}


// function to make a broad range of colors available by 
// a single number between 0 and 1
color linearColor(float theValue) {
  pushStyle();
  colorMode(HSB, 360, 100, 100, 100);

  float h = (theValue) * 360;
  float s = abs(sin((1-theValue) * PI * 9)) * 60 + (1-theValue)*40;
  float b = abs(cos((1-theValue) * PI * 4.5)) * 60 + (theValue)*40;
  color newColor = color(h, s, b);

  popStyle();

  return newColor;
}


// ------ key and mouse events ------

void keyPressed(){
  if (!myWikipediaGraph.editing) {
    if(key=='m' || key=='M') {
      GUI = controlP5.getGroup("menu").isOpen();
      GUI = !GUI;
    }
    if (GUI) controlP5.getGroup("menu").open();
    else controlP5.getGroup("menu").close();

    if (key=='1') {
      colorizeNodes = !colorizeNodes;
      Toggle t = (Toggle) controlP5.getController("colorizeNodes");
      t.setState(colorizeNodes);
    }
    if (key=='2') {
      drawFishEyed = !drawFishEyed;
      Toggle t = (Toggle) controlP5.getController("drawFishEyed");
      t.setState(drawFishEyed);
    }

    if (keyCode == UP) zoom += 0.05;
    if (keyCode == DOWN) zoom -= 0.05;
    zoom = max(zoom, 0.1);

    if(key=='s' || key=='S') {
      saveOneFrame = true; 
    }
    if(key=='p' || key=='P') {
      savePDF = true; 
      println("saving to pdf - starting (this may take some time)");
    }
  }
}


void mousePressed() {
  lastMouseButton = mouseButton;
  
  if (!guiEvent) {
    // tell graph that mouse was pressed
    boolean eventHandled = myWikipediaGraph.mousePressed();
    // if the graph didn't do anything with the mouse event
    if (!eventHandled) {
      // canvas dragging
      if (mouseButton==RIGHT) {
        dragging = true;
        clickX = mouseX;
        clickY = mouseY;
        clickOffsetX = myWikipediaGraph.offset.x;
        clickOffsetY = myWikipediaGraph.offset.y;
      }
    }
  }
}


void mouseReleased() {
  if (!guiEvent) {
    boolean eventHandled = myWikipediaGraph.mouseReleased();
  }
  guiEvent = false;
  dragging = false;
}


void mouseEntered(MouseEvent e) {
  loop();
}

void mouseExited(MouseEvent e) {
  noLoop();
}


String timestamp() {
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", Calendar.getInstance());
}