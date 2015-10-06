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


class WikipediaGraph {

  // we use a HashMap to store the nodes, because we frequently have to find them by their id,
  // which is easy to do with a HashMap
  HashMap nodeMap = new HashMap();

  float minClickDiameter = 20;
  // hovered node
  Node rolloverNode = null;
  // node that is dragged with the mouse
  Node selectedNode = null;
  // node for which loading is in progress
  Node loadingNode = null;
  // node that was clicked on
  WikipediaNode clickedNode;

  int resultCount = 10;

  // we use an ArrayList because it is faster to append with new springs
  ArrayList springs = new ArrayList();

  // default parameters
  float springLength = 100;
  float springStiffness = 0.4;
  float springDamping = 0.9;

  float nodeRadius = 200;
  float nodeStrength = -15;
  float nodeDamping = 0.5;

  boolean invertBackground = true;
  boolean drawFishEyed = true;

  PFont font;
  float textsize;
  float lineWeight = 3;
  float lineAlpha = 100;
  color linkColor = color(0);

  boolean colorizeNodes = true;
  float minNodeDiameter = 3;
  float nodeDiameterFactor = 1;

  // arrays for text analysis
  Pattern[] patterns = new Pattern[0];
  color[] colors = new color[0];

  boolean showText = true;
  boolean showRolloverText = true;
  boolean showRolloverNeighbours = false;

  float minX = 0;
  float minY = 0;
  float maxX = width;
  float maxY = height;

  boolean autoZoom = true;
  float zoom = 1;
  float targetZoom = 1;
  // center of the boundaries of the graph
  PVector center = new PVector();
  // 
  PVector offset = new PVector();
  PVector targetOffset = new PVector();

  // helpers
  int pMillis = millis();
  // for pdf output we need to freeze time to 
  // prevent text from disappearing
  boolean freezeTime = false;

  // new node edit
  boolean editing = false;
  ControlP5 editControls = new ControlP5(root);
  Textfield editTextfield;
  WikipediaNode editNode;



  WikipediaGraph() {
    font = createFont("miso-regular.ttf",12);
    String s;

    // keywords for coloing the nodes
    // scientific -> blue
    s = "model|theory|structur|component|element|concept|experiment|mathematic|chemi|device|biology|engineer|physic|scientific|science";
    patterns = (Pattern[]) append(patterns, Pattern.compile(s));
    colors = append(colors, color(0, 130, 164));

    // geography, politics -> yellow
    s = "climate|histor|planet|plant|population|ethnic|politic|atmosphere|treaty";
    patterns = (Pattern[]) append(patterns, Pattern.compile(s));
    colors = append(colors, color(181, 157, 0));

    // culture, arts -> purple
    s = "design|jazz|sculpture|culture|music|opus|period|composer|perform|literature|author|drama|poet|genre|fiction|theatre|style";
    patterns = (Pattern[]) append(patterns, Pattern.compile(s));
    colors = append(colors, color(89, 34, 131));
  }


  Node addNode(String theID, float theX, float theY) {
    // check if node is already there
    Node findNode = (Node) nodeMap.get(theID);

    if (findNode == null) {
      // create a new node
      Node newNode = new WikipediaNode(this, theX, theY);

      newNode.setID(theID);
      newNode.setDamping(nodeDamping);
      newNode.setStrength(nodeStrength);
      newNode.setRadius(nodeRadius);

      nodeMap.put(theID, newNode);

      return newNode;
    } 
    else {
      return null; 
    }
  }

  void removeNode(Node theNode) {
    int i;
    // remove springs from/to theNode
    for (i = springs.size()-1; i >= 0; i--) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theNode || s.toNode == theNode) {
        WikipediaNode from = (WikipediaNode) s.fromNode;
        from.linkCount--;
        WikipediaNode to = (WikipediaNode) s.toNode;
        to.backlinkCount--;
        springs.remove(i);
      }
    }

    // remove theNode
    nodeMap.remove(theNode.id);

    // remove single nodes
    Iterator iter = nodeMap.entrySet().iterator();
    while (iter.hasNext()) {
      Map.Entry me = (Map.Entry) iter.next();
      WikipediaNode node = (WikipediaNode) me.getValue();
      if (getSpringIndexByNode(node) < 0 && !node.wasClicked) {
        iter.remove();
      }
    }
  }


  Spring addSpring(String fromID, String toID) {
    WikipediaNode fromNode = (WikipediaNode) nodeMap.get(fromID);
    WikipediaNode toNode = (WikipediaNode) nodeMap.get(toID);

    // if one of the nodes do not exist, stop creating spring
    if (fromNode==null) return null;
    if (toNode==null) return null;

    if (getSpring(fromNode, toNode) == null) {
      // create a new spring
      Spring newSpring = new Spring(fromNode, toNode, springLength, springStiffness, 0.9);
      springs.add(newSpring);

      fromNode.linkCount++;
      toNode.backlinkCount++;

      return newSpring;
    }

    return null;
  }


  Node getNodeByID(String theID) {
    Node node = (Node) nodeMap.get(theID); 
    return node;
  }


  Node getNodeByScreenPos(float theX, float theY) {
    float mx = (theX-width/2)/zoom-offset.x;
    float my = (theY-height/2)/zoom-offset.y;

    return getNodeByPos(mx, my);
  }


  Node getNodeByPos(float theX, float theY) {
    Node selectedNode = null;
    Iterator i = nodeMap.entrySet().iterator();
    while (i.hasNext()) {
      Map.Entry me = (Map.Entry) i.next();
      WikipediaNode checkNode = (WikipediaNode) me.getValue();

      float d = dist(theX, theY, checkNode.sx, checkNode.sy);
      if (d < max(checkNode.diameter/2, minClickDiameter)) {
        selectedNode = (Node) checkNode;
      }
    }
    return selectedNode;
  }

  int getSpringIndexByNode(Node theNode) {
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theNode || s.toNode == theNode) {
        return i;
      }
    }
    return -1;
  }

  Spring getSpring(Node theFromNode, Node theToNode) {
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theFromNode && s.toNode == theToNode) {
        return s;
      }
    }
    return null;
  }


  float getZoom() {
    return targetZoom;
  }
  void setZoom(float theZoom) {
    targetZoom = theZoom; 
  }

  PVector getOffset() {
    return new PVector(offset.x, offset.y);
  }

  void setOffset(float theOffsetX, float theOffsetY) {
    offset.x = theOffsetX; 
    offset.y = theOffsetY; 
    targetOffset.x = offset.x; 
    targetOffset.y = offset.y; 
  }

  Node getLoadingNode() {
    return loadingNode;
  }
  void setLoadingNode(Node theNode) {
    loadingNode = theNode;
  }
  boolean isLoading(Node theNode) {
    if (theNode == loadingNode) return true;
    return false;
  }

  boolean isRollover(Node theNode) {
    if (theNode == rolloverNode) return true;
    return false;
  }
  boolean isRolloverNeighbour(Node theNode) {
    if (getSpring(theNode, rolloverNode) != null) return true;
    if (getSpring(rolloverNode, theNode) != null) return true;
    return false;
  }

  boolean isSelected(Node theNode) {
    if (theNode == selectedNode) return true;
    return false;
  }

  int getMillis() {
    if (freezeTime) {
      return pMillis;
    }
    return millis();
  }


  void setResultCount(int theResultCount) {
    resultCount = theResultCount;
  }

  void setSpringLength(float theLength) {
    if (theLength != springLength) { 
      springLength = theLength;
      for (int i = 0; i < springs.size(); i++) {
        Spring s = (Spring) springs.get(i);
        s.setLength(springLength);     
      }
    }
  }

  void setSpringStiffness(float theStiffness) {
    if (theStiffness != springStiffness) { 
      springStiffness = theStiffness;
      for (int i = 0; i < springs.size(); i++) {
        Spring s = (Spring) springs.get(i);
        s.setStiffness(springStiffness);     
      }
    }
  }

  void setSpringDamping(float theDamping) {
    if (theDamping != springDamping) { 
      springDamping = theDamping;
      for (int i = 0; i < springs.size(); i++) {
        Spring s = (Spring) springs.get(i);
        s.setDamping(springDamping);     
      }
    }
  }

  void setNodeRadius(float theRadius) {
    if (theRadius != nodeRadius) { 
      nodeRadius = theRadius;
      Iterator i = nodeMap.entrySet().iterator();
      while (i.hasNext()) {
        Map.Entry me = (Map.Entry) i.next();
        Node node = (Node) me.getValue();
        node.setRadius(nodeRadius);
      }
    }
  }

  void setNodeStrength(float theStrength) {
    if (theStrength != nodeStrength) { 
      nodeStrength = theStrength;
      Iterator i = nodeMap.entrySet().iterator();
      while (i.hasNext()) {
        Map.Entry me = (Map.Entry) i.next();
        Node node = (Node) me.getValue();
        node.setStrength(nodeStrength);
      }
    }
  }

  void setNodeDamping(float theDamping) {
    if (theDamping != nodeDamping) { 
      nodeDamping = theDamping;
      Iterator i = nodeMap.entrySet().iterator();
      while (i.hasNext()) {
        Map.Entry me = (Map.Entry) i.next();
        Node node = (Node) me.getValue();
        node.setDamping(nodeDamping);
      }
    }
  }


  void setInvertBackground(boolean theInvertBackground) {
    invertBackground = theInvertBackground;  
  }

  void setDrawHyperbolic(boolean theDrawHyperbolic) {
    drawFishEyed = theDrawHyperbolic;  
  }

  void setLineWeight(float theLineWeight) {
    lineWeight = theLineWeight;  
  }

  void setLineAlpha(float theLineAlpha) {
    lineAlpha = theLineAlpha;  
  }


  void setColorizeNodes(boolean theValue) {
    colorizeNodes = theValue;
  }

  void setMinNodeDiameter(float theValue) {
    minNodeDiameter = theValue;
  }

  void setNodeDiameterFactor(float theValue) {
    nodeDiameterFactor = theValue;
  }


  void setLinkColor(color theLinkColor) {
    linkColor = theLinkColor;  
  }

  void setShowText(boolean theShowText) {
    showText = theShowText;
  }

  void setShowRolloverText(boolean theShowRolloverText) {
    showRolloverText = theShowRolloverText;
  }

  void setShowRolloverNeighbours(boolean theShowRolloverNeighbours) {
    showRolloverNeighbours = theShowRolloverNeighbours;
  }


  PVector screenPos(PVector thePos) {
    if (drawFishEyed) {      
      // position of the node transformed, so that x and y is 0 
      // if the node is in the center of the screen
      float x = thePos.x + offset.x / zoom;
      float y = thePos.y + offset.y / zoom;
      // get polar coordinates of the point
      float[] pol = GenerativeDesign.cartesianToPolar(x, y);
      float distance = pol[0];
      
      // fisheye projection
      float radius = min(width, height)/2;
      float distAngle = atan(distance/(radius/2)*zoom) / HALF_PI;
      float newDistance = distAngle * radius / zoom;
      
      // transform polar coordinates back into cartesian coordinates
      float[] newPos = GenerativeDesign.polarToCartesian(newDistance, pol[1]);
      // new position
      float newX = newPos[0]-offset.x;
      float newY = newPos[1]-offset.y;
      float newScale = min(1.2-distAngle, 1);
      return new PVector(newX, newY, newScale);
    }
    else {
      return new PVector(thePos.x, thePos.y, 1);
    }
  }

  PVector localToGlobal(float theX, float theY) {
    float mx = (theX+offset.x)*zoom+width/2;
    float my = (theY+offset.y)*zoom+height/2;

    return new PVector(mx, my);
  }

  PVector globalToLocal(float theX, float theY) {
    float mx = (theX-width/2)/zoom-offset.x;
    float my = (theY-height/2)/zoom-offset.y;

    return new PVector(mx, my);
  }



  String toString() {
    String s = "";

    Iterator i = nodeMap.entrySet().iterator();
    while (i.hasNext()) {
      Map.Entry me = (Map.Entry) i.next();
      Node node = (Node) me.getValue();
      s += node.toString() + "\n";
    }
    return (s);
  }


  void update() {
    // use this function also to get actual width and heigth of the graph
    minX = Float.MAX_VALUE; 
    minY = Float.MAX_VALUE;
    maxX = -Float.MAX_VALUE; 
    maxY = -Float.MAX_VALUE;

    // make an Array out of the values in nodeMap
    Node[] nodes = (Node[]) nodeMap.values().toArray(new Node[0]);

    for (int i = 0; i < nodes.length; i++) {
      nodes[i].attract(nodes);
    }
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s == null) break;
      s.update();
    }
    for (int i = 0; i < nodes.length; i++) {
      nodes[i].update();

      minX = min(nodes[i].x, minX);
      maxX = max(nodes[i].x, maxX);
      minY = min(nodes[i].y, minY);
      maxY = max(nodes[i].y, maxY);
    }

    if (selectedNode != null) {
      // when dragging a node
      selectedNode.x = (mouseX - width/2)/zoom - offset.x;
      selectedNode.y = (mouseY - height/2)/zoom - offset.y;
    } 
    else if (autoZoom) {
      // otherwise recalc zoom, center and offset
      center.set((minX+maxX)/2, (minY+maxY)/2, 0);
      targetOffset.set(-center.x, -center.y, 0);

      float dx = maxX - minX;
      float dy = maxY - minY;
      float qx = 100;
      float qy = 100;
      if (dx > 0) qx = (width-50)/dx;
      if (dy > 0) qy = (height-50)/dy;
      targetZoom = min(min(qx, qy), 1);
    }

    // check if there is a node hovered    
    rolloverNode = getNodeByScreenPos(mouseX, mouseY);

  }


  void draw() {
    //  TextField tf = (TextField) controlP5.getController("editText");
    if (!editing && editTextfield != null) {
      controlP5.remove("editText");
    }

    if (editTextfield != null) {
      PVector sp = localToGlobal(editNode.sx, editNode.sy);
      editTextfield.setPosition(int(sp.x+10), int(sp.y-10));
      editTextfield.setFocus(true);
      //editControls.draw();
    }

    int dt = 0;
    if (!freezeTime) {
      int m = millis();
      dt = m - pMillis;    
      pMillis = m;
    }

    // smooth movement of canvas
    PVector d = new PVector();

    float accomplishPerSecond = 0.95;
    float f = pow(1/(1-accomplishPerSecond), -dt/1000.0);

    d = PVector.sub(targetOffset, offset);
    d.mult(f);
    offset = PVector.sub(targetOffset, d);

    zoom = targetZoom - ((targetZoom - zoom) * f);


    pushStyle();

    pushMatrix();
    translate(width/2, height/2);
    scale(zoom);
    translate(offset.x, offset.y);

    Iterator iter = nodeMap.entrySet().iterator();
    while (iter.hasNext()) {
      Map.Entry me = (Map.Entry) iter.next();
      WikipediaNode node = (WikipediaNode) me.getValue();

      node.loaderLoop();
    }


    colorMode(HSB, 360, 100, 100, 100);

    // draw origin
    // fill (0, 100, 100);
    // ellipse(0, 0, 4, 4);

    // draw springs
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s == null) break;
      stroke(hue(linkColor), saturation(linkColor), brightness(linkColor), lineAlpha);
      strokeWeight(lineWeight);
      drawArrow((WikipediaNode) s.fromNode, (WikipediaNode) s.toNode);
      noStroke();
    }

    // draw nodes
    colorMode(RGB, 255, 255, 255, 100);

    iter = nodeMap.entrySet().iterator();
    while (iter.hasNext()) {
      Map.Entry me = (Map.Entry) iter.next();
      WikipediaNode node = (WikipediaNode) me.getValue();
      node.draw();
    }

    // draw node labels 
    iter = nodeMap.entrySet().iterator();
    while (iter.hasNext()) {
      Map.Entry me = (Map.Entry) iter.next();
      WikipediaNode node = (WikipediaNode) me.getValue();
      node.drawLabel();
    }

    popMatrix();

    popStyle();
  }


  void drawArrow(WikipediaNode n1, WikipediaNode n2) {

    PVector d = new PVector(n2.sx - n1.sx, n2.sy - n1.sy);
    float margin1 = n1.diameter*n1.sfactor/2.0 + 3 + lineWeight/2;
    float margin2 = n2.diameter*n2.sfactor/2.0 + 3 + lineWeight/2;

    if (d.mag() > margin1+margin2) {
      d.normalize();
      line(n1.sx+d.x*margin1, n1.sy+d.y*margin1, n2.sx-d.x*margin2, n2.sy-d.y*margin2);

      float a = atan2(d.y, d.x);
      pushMatrix();
      translate(n2.sx-d.x*margin2, n2.sy-d.y*margin2);
      rotate(a);
      float l = 1 + lineWeight;
      line(0, 0, -l, -l);
      line(0, 0, -l, l);
      popMatrix();

    }
  }


  float getWidth() {
    return 1;
  }

  String encodeURL(String name) {
    StringBuffer sb = new StringBuffer();
    byte[] utf8 = name.getBytes();
    for (int i = 0; i < utf8.length; i++) {
      int value = utf8[i] & 0xff;
      if (value < 33 || value > 126) {
        sb.append('%');
        sb.append(hex(value, 2));
      } 
      else {
        sb.append((char) value);
      }
    }
    return sb.toString();
  } 


  color textToColor(String theText) {
    int i;
    int len = patterns.length;
    int[] counters = new int[len];
    int[] counterSums = new int[len];

    Matcher m;
    for (i = 0; i < len; i++) {
      m = patterns[i].matcher(theText.toLowerCase());
      while (m.find() == true) {
        counters[i]++;
      }
    }

    // sumarize counters
    counterSums[0] = counters[0];
    for (i = 1; i < len; i++) {
      counterSums[i] = counterSums[i-1] + counters[i];
    }
    // if all counters are 0, return black
    if (counterSums[len-1] == 0) {
      return color(0);
    }

    // interpolate colors
    color result = colors[0];
    for (i = 1; i < len; i++) {
      float amount = counters[i]/float(counterSums[i]);
      result = lerpColor(result, colors[i], amount);
    }
    return result;
  }


  boolean mousePressed() {
    clickedNode = (WikipediaNode) getNodeByScreenPos(mouseX, mouseY);

    if (clickedNode != null) {
      if (mouseButton == RIGHT) {
        selectedNode = clickedNode;

        // double click right -> open page in browser
        if (mouseEvent.getClickCount()==2) {
          link("http://en.wikipedia.org/wiki/"+encodeURL(clickedNode.id)); 
        }
        return true;
      }

    } 

    return false;
  }


  boolean mouseReleased() {
    if (selectedNode != null) {
      selectedNode = null;
    }

    if (clickedNode != null) {

      if (lastMouseButton == LEFT) {

        if (keyPressed && keyCode == SHIFT) {
          // delete clicked node
          if (clickedNode == editNode) {
            editing = false;
            //controlP5.remove("editText");
          }

          removeNode(clickedNode);
          return true;
        }
        else if (!keyPressed) {
          clickedNode.wasClicked = true;
          // load links from clicked node
          if (clickedNode.availableLinksLoaded) {
            int addedNodes = 0;
            for (int i = 0; i < clickedNode.availableLinks.size(); i++) {
              if (addedNodes >= resultCount) break;

              String title = (String) clickedNode.availableLinks.get(i);

              Node addedNode = addNode(title, clickedNode.x+random(-5, 5), clickedNode.y+random(-5, 5));
              if (addedNode != null) addedNodes++;

              Spring addedSpring = addSpring(clickedNode.id, title);
            }
          }
          return true;
        }
        else if (keyPressed && keyCode == ALT) {
          clickedNode.wasClicked = true;
          // load links to clicked node
          if (clickedNode.availableBacklinksLoaded ) {

            int addedNodes = 0;
            for (int i = 0; i < clickedNode.availableBacklinks.size(); i++) {
              if (addedNodes >= resultCount) break;

              String title = (String) clickedNode.availableBacklinks.get(i);

              //if (myWikipediaGraph.getNodeByID(title) == null) {
              Node addedNode = addNode(title, clickedNode.x+random(-5, 5), clickedNode.y+random(-5, 5));
              if (addedNode != null) addedNodes++;

              Spring addedSpring = addSpring(title, clickedNode.id);
            }

          }
          return true;
        }

      }
    } 
    else {
      // doubleclick on canvas
      if (lastMouseButton == LEFT) {
        if (mouseEvent.getClickCount()==2) {
          if (!editing) {
            // create new node
            editing = true;

            PVector p = globalToLocal(mouseX, mouseY);
            editNode = (WikipediaNode) addNode("", p.x, p.y);

            editTextfield = controlP5.addTextfield("editText",mouseX,mouseY,150,20);
            editTextfield.setFocus(true);
            editTextfield.setColorBackground(color(255));
            editTextfield.setColorValueLabel(color(0));
            editTextfield.setLabel("");

            return true;
          }
        }
      }
    }

    return false;
  }

  void confirmEdit(String theText) {
    editing = false;

    float px = editNode.x;
    float py = editNode.y;
    removeNode(editNode);
    WikipediaNode newNode = (WikipediaNode) addNode(theText, px, py);
    newNode.wasClicked = true;
    // controlP5.remove("editText");

    guiEvent = false;
  }

}