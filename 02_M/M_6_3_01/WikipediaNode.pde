// M_6_3_01.pde
// WikipediaGraph.pde, WikipediaNode.pde
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

class WikipediaNode extends Node {

  // reference to the force directed graph
  WikipediaGraph graph;

  // available links
  XML linksXML;
  boolean availableLinksLoaded = false;
  ArrayList availableLinks = new ArrayList();

  // available backlinks
  XML backlinksXML;
  boolean availableBacklinksLoaded = false;
  ArrayList availableBacklinks = new ArrayList();

  // look of the node
  color nodeColor = color(0);
  float nodeDiameter = 20;
  // size of the displayed text
  float textsize = 18;
  // behaviour parameters
  float nodeRadius = 200;
  float nodeStrength = -15;
  float nodeDamping = 0.5;

  // last activation (rollover) time
  int activationTime;
  // is this a node that was clicked on
  boolean wasClicked = false;


  WikipediaNode(WikipediaGraph theGraph) {
    super();
    graph = theGraph;
    init();
  }

  WikipediaNode(WikipediaGraph theGraph, float theX, float theY) {
    super(theX, theY);
    graph = theGraph;
    init();
  }

  WikipediaNode(WikipediaGraph theGraph, float theX, float theY, float theZ) {
    super(theX, theY, theZ);
    graph = theGraph;
    init();
  }

  WikipediaNode(WikipediaGraph theGraph, PVector theVector) {
    super(theVector);
    graph = theGraph;
    init();
  }

  void init() {
    activationTime = millis();
    diameter = nodeDiameter + 6;

    setDamping(nodeDamping);
    setStrength(nodeStrength);
    setRadius(nodeRadius);
  }


  void setID(String theID) {
    super.setID(theID);

    // load available links
    availableLinksLoaded = false;
    availableLinks = new ArrayList();
    String url = encodeURL("http://en.wikipedia.org/w/api.php?format=xml&action=query&prop=links&titles="+id+"&pllimit=500&plnamespace=0&redirects");
    linksXML = GenerativeDesign.loadXMLAsync(thisPApplet, url);

    // load available backlinks
    availableBacklinksLoaded = false;
    availableBacklinks = new ArrayList();
    url = encodeURL("http://en.wikipedia.org/w/api.php?format=xml&action=query&list=backlinks&bltitle="+id+"&bllimit=500&blnamespace=0&blredirect");
    backlinksXML = GenerativeDesign.loadXMLAsync(thisPApplet, url);
  }


  void loaderLoop() {
    // handle loading of links
    if (!availableLinksLoaded) {
      if (linksXML.getChildCount() > 0) {
        // get titles of links
        XML[] children = linksXML.getChildren("query/pages/page/links/pl"); 
        for (int i = 1; i < children.length; i++) {
          String title = children[i].getString("title");
          availableLinks.add(title);
        }

        XML querycontinue = linksXML.getChild("query-continue/links");
        if (querycontinue == null) {
          availableLinksLoaded = true;
          GenerativeDesign.unsort(availableLinks);
        } 
        else {
          String plcontinue = querycontinue.getString("plcontinue");
          String url = encodeURL("http://en.wikipedia.org/w/api.php?format=xml&action=query&prop=links&titles="+id+"&pllimit=500&plnamespace=0&plcontinue="+plcontinue);
          linksXML = GenerativeDesign.loadXMLAsync(thisPApplet, url);
        }
      } 
    }

    // handle loading of backlinks
    if (!availableBacklinksLoaded) {
      if (backlinksXML.getChildCount() > 0) {
        // get titles of backlinks
        XML[] children = backlinksXML.getChildren("query/backlinks/bl"); 
        for (int i = 1; i < children.length; i++) {
          String title = children[i].getString("title");
          availableBacklinks.add(title);
        }

        XML querycontinue = backlinksXML.getChild("query-continue/backlinks");
        if (querycontinue == null) {
          availableBacklinksLoaded = true;
          GenerativeDesign.unsort(availableBacklinks);
        } 
        else {
          String blcontinue = querycontinue.getString("blcontinue");
          String url = encodeURL("http://en.wikipedia.org/w/api.php?format=xml&action=query&list=backlinks&bltitle="+id+"&bllimit=500&blnamespace=0&blcontinue="+blcontinue);
          backlinksXML = GenerativeDesign.loadXMLAsync(thisPApplet, url);
        }
      } 
    }
  }


  void draw() {
    float d;
    // while loading draw grey ring around node
    d = diameter;
    if (graph.isLoading(this)) {
      fill(128);
      ellipse(x, y, d, d);
    } 

    // white ring between center circle and link ring
    d = diameter;
    fill(255);
    ellipse(x, y, d, d);

    // main dot
    d = (diameter - 6);
    pushStyle();
    fill(0);
    ellipse(x, y, d, d);
    popStyle();
  }


  void drawLabel() {
    // draw text
    textAlign(LEFT);
    rectMode(CORNER);
    float tfactor = 1;

    // draw text for rolloverNode
    if (graph.showText) {
      if (wasClicked || (graph.isRollover(this) && graph.showRolloverText)) {
        activationTime = graph.getMillis();

        float ts = textsize/pow(graph.zoom, 0.5) *tfactor;
        textFont(graph.font, ts);

        float tw = textWidth(id);
        fill(255, 80);
        rect(x+ (diameter/2+4)*tfactor, y-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
        fill(80);
        if (graph.isRollover(this) && graph.showRolloverText) {
          fill(0);
        }
        text(id, x+(diameter/2+5)*tfactor, y+6*tfactor);
      } 
      else {
        // draw text for all nodes that are linked to the rollover node
        if (wasClicked || graph.showRolloverNeighbours) {
          if (graph.isRolloverNeighbour(this)) {
            activationTime = graph.getMillis();
          }
        }

        int dt = graph.getMillis() - activationTime;
        if (dt < 10000) {
          float ts = textsize/pow(graph.zoom, 0.5)*tfactor;
          textFont(graph.font, ts);

          float tw = textWidth(id);
          float a = min(3*(1-dt/10000.0), 1) * 100;
          fill(255, a*0.8);
          rect(x+(diameter/2+4)*tfactor, y-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
          fill(80, a);
          text(id, x+(diameter/2+5)*tfactor, y+6*tfactor);
        }
      }
    }
  }

}