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

class WikipediaNode extends Node {

  // screenPosition and screenScalingFactor
  float sx = 0;
  float sy = 0;
  float sfactor = 1;
  // reference to the force directed graph
  WikipediaGraph graph;
  // last activation (rollover) time
  int activationTime;
  // is this a node that was clicked on
  boolean wasClicked = false;
  // this will contain the respective html as an ArrayList (each line as a string)
  ArrayList htmlList = new ArrayList();
  String htmlString = "";
  boolean htmlLoaded = false;
  // available links
  boolean availableLinksLoaded = false;
  ArrayList availableLinks = new ArrayList();
  XML linksXML;
  // number of links already shown
  int linkCount = 0;
  float ringRadius = 0;
  // available backlinks
  boolean availableBacklinksLoaded = false;
  ArrayList availableBacklinks = new ArrayList();
  XML backlinksXML;
  // number of links pointing to this node
  int backlinkCount = 0;
  // size of the displayed text
  float textsize = 18;
  // color of the node
  color nodeColor = color(0);


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
  }


  void setID(String theID) {
    super.setID(theID);

    if (!theID.equals("")) {
      // load html
      htmlLoaded = false;
      htmlString = "";
      String url = encodeURL("https://en.wikipedia.org/wiki/"+id);
      htmlList = GenerativeDesign.loadHTMLAsync(thisPApplet, url, GenerativeDesign.HTML_CONTENT);

      // load available links
      availableLinksLoaded = false;
      availableLinks = new ArrayList();
      url = encodeURL("http://en.wikipedia.org/w/api.php?format=xml&action=query&prop=links&titles="+id+"&pllimit=500&plnamespace=0&redirects");
      linksXML = GenerativeDesign.loadXMLAsync(thisPApplet, url);

      // load available backlinks
      availableBacklinksLoaded = false;
      availableBacklinks = new ArrayList();
      url = encodeURL("http://en.wikipedia.org/w/api.php?format=xml&action=query&list=backlinks&bltitle="+id+"&bllimit=500&blnamespace=0&blredirect");
      backlinksXML = GenerativeDesign.loadXMLAsync(thisPApplet, url);
    }
    //  }
  }


  void loaderLoop() {
    // handle loading of html
    if (!id.equals("")) {
      if (!htmlLoaded) {
        try {
          if (htmlList.size() > 0 && htmlString.length() == 0) {
            htmlString = htmlList.toString();
            htmlLoaded = true;
            nodeColor = graph.textToColor(htmlString);
          }
        } 
        catch (Exception e) {
          println("Error during asyncHTMLLoad - but no problem");
        }
      }

      // handle loading of links
      if (!availableLinksLoaded) {
        if (linksXML.getChildCount() > 0) {
          // linksXML = linksXML.getChild(0);

          // get normalization, if available
          //XML[] normalization = linksXML.getChildren("query/normalized/n");
          //println(normalization.length);
          //if (normalization.length > 0) {
          //  String to = normalization[0].getStringAttribute("to");
          //  super.setID(to);
          //}

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
          // backlinksXML = backlinksXML.getChild(0);

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
  }


  void update() {
    super.update();

    PVector spos = graph.screenPos(this);
    sx = spos.x;
    sy = spos.y;
    sfactor = spos.z;

    // length of the text of the article (ignore 1500 chars 
    // that are used for menu and other stuff)
    float l = max(htmlString.length()-1500, 0);
    // make this number a lot smaller and keep it from growing to fast
    l = sqrt(l/10000.0);
    // diameter of the main dot
    diameter = graph.minNodeDiameter + graph.nodeDiameterFactor * l;

    // thickness of the ring around the node
    int hiddenLinkCount = availableLinks.size()-linkCount;
    hiddenLinkCount = max(0, hiddenLinkCount);
    ringRadius = 1 + sqrt(hiddenLinkCount / 2.0);
    diameter += 6;
    diameter += ringRadius;
  }



  void draw() {
    float d;
    // while loading draw grey ring around node
    d = diameter*sfactor;
    if (graph.isLoading(this)) {
      fill(128);
      ellipse(sx, sy, d, d);
    } 
    else if (!htmlLoaded) {
      fill(128);
      ellipse(sx, sy, d, d);
    } 

    color col = nodeColor;
    if (graph.invertBackground && nodeColor == color(0)) {
      col = color(255); 
    }

    // ring for outgoing links
    if (linkCount < availableLinks.size()) {
      d = diameter*sfactor;
      pushStyle();
      fill(128);
      colorMode(HSB, 360, 100, 100, 100);
      if (graph.colorizeNodes) {
        float s = saturation(col);
        float b = brightness(col);
        if (graph.invertBackground) {
          s *= 0.8;
          b = b*0.5;
        } 
        else {
          s *= 0.3;
          b = 100-(100-b)*0.5;
        }
        fill(hue(col), s, b);
      }
      ellipse(sx, sy, d, d);
      popStyle();
    }

    // white ring between center circle and link ring
    d = (diameter - ringRadius)*sfactor;
    fill(255);
    if (graph.invertBackground) fill(0);
    ellipse(sx, sy, d, d);

    // main dot
    if (htmlLoaded) {
      d = (diameter - ringRadius - 6)*sfactor;

      //fill(graph.nodeColor);
      pushStyle();
      fill(0);
      if (graph.invertBackground) fill(255);
      if (graph.colorizeNodes) {
        colorMode(HSB, 360, 100, 100, 100);
        fill(col);
      }
      ellipse(sx, sy, d, d);
      popStyle();
    }

    // center dot for backlinks
    if (backlinkCount < availableBacklinks.size()) {
      d = min((diameter-6-ringRadius)/2, 4)*sfactor;
      fill(255);
      if (graph.invertBackground) fill(0);
      ellipse(sx, sy, d, d);
    }

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
        if (graph.invertBackground) fill(0, 80);
        rect(sx+ (diameter/2+4)*tfactor*sfactor, sy-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
        fill(80);
        if (graph.isRollover(this) && graph.showRolloverText) {
          fill(0);
          if (graph.invertBackground) fill(255);
        }
        text(id, sx+(diameter/2+5)*tfactor*sfactor, sy+6*tfactor);
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
          if (graph.invertBackground) fill(0, a*0.8);
          rect(sx+(diameter/2+4)*tfactor*sfactor, sy-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
          fill(80, a);
          text(id, sx+(diameter/2+5)*tfactor*sfactor, sy+6*tfactor);
        }
      }
    }

  }


}