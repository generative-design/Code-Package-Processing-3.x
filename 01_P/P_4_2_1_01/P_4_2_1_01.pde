// P_4_2_1_01.pde
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
 * collage generator. example footage can be found in "_4_2_1_footage".
 * if you use your own footage, make sure to rename the files or adjust the prefixes: 
 * see the parameters of generateCollageItems()
 * 
 * KEYS
 * 1-3                  : create a new collage (layer specific)
 * s                    : save png
 */

import java.util.Calendar;

PImage[] images;
String[] imageNames;
int imageCount;

CollageItem[] layer1Items, layer2Items, layer3Items;


void setup() {
  size(1024, 768);
  imageMode(CENTER);
  background(255);

  // ------ load images ------
  // replace this location with a folder on your machine or use selectInput()
  File dir = new File(sketchPath(""),"../P_4_2_1_footage");

  if (dir.isDirectory()) {
    String[] contents = dir.list();
    images = new PImage[contents.length]; 
    imageNames = new String[contents.length]; 
    for (int i = 0 ; i < contents.length; i++) {
      // skip hidden files and folders starting with a dot, load .png files only
      if (contents[i].charAt(0) == '.') continue;
      else if (contents[i].toLowerCase().endsWith(".png")) {
        File childFile = new File(dir, contents[i]);        
        images[imageCount] = loadImage(childFile.getPath());
        imageNames[imageCount] = childFile.getName();
        println(imageCount+" "+contents[i]+"  "+childFile.getPath());
        imageCount++;             
      }
    }
  }

  // ------ init ------
  // generateCollageItems(filename prefix, count, x,y, range x,range y, scale start,scale end, rotation start,rotation end)
  // filname prefix               : Alle Bilder, deren Name so beginnt, werden für diesen Layer verwendet
  // count                        : Anzahl der Bilder
  // x,y                          : Position, um die sich die Bilder scharen
  // range x, range y             : So weit werden die Positionen in x- und y-Richtung gestreut
  // scale start, scale end       : Minimaler und maximaler Wert für den zufälligen Skalierungsfaktor
  // rotation start, rotation end : Minimaler und maximaler Wert für den zufälligen Rotationswinkel
  
  layer1Items = generateCollageItems("layer1", 100, width/2,height/2, width,height, 0.1,0.5, 0,0);
  layer2Items = generateCollageItems("layer2", 150, width/2,height/2, width,height, 0.1,0.3, -PI/2,PI/2);
  layer3Items = generateCollageItems("layer3", 110, width/2,height/2, width,height, 0.1,0.85, 0,0);


  // draw collage
  drawCollageItems(layer1Items);
  drawCollageItems(layer2Items);
  drawCollageItems(layer3Items); 
}

void draw() {
  // keep the programm running
}


// ------ interactions and generation of the collage ------
void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");

  if (key == '1') layer1Items = generateCollageItems("layer1", (int)random(50,200), width/2,height/2,width,height, 0.1,0.5, 0,0);
  if (key == '2') layer2Items = generateCollageItems("layer2", (int)random(25,300), 200,height*0.75,width,150, 0.1,random(0.3,0.8), -PI/2,PI/2);
  if (key == '3') layer3Items = generateCollageItems("layer3", (int)random(50,300), width/2,height*0.66,width,height*0.66, 0.1,random(0.4,0.8), -0.05,0.05);

  // draw collage
  background(255);
  drawCollageItems(layer1Items);
  drawCollageItems(layer2Items);
  drawCollageItems(layer3Items);
}


// ------ collage class/record ------
class CollageItem {
  float x = 0, y = 0;
  float rotation = 0;
  float scaling = 1;
  int indexToImage = -1;
}


// ------ collage items helper functions ------
CollageItem[] generateCollageItems(String thePrefix, int theCount, float thePosX, float thePosY, float theRangeX, float theRangeY, float theScaleStart, float theScaleEnd, float therotationStart, float therotationEnd) {
  // collect all images with the specified prefix
  int[] indexes = new int[0];
  for (int i = 0 ; i < imageNames.length; i++) {
    if (imageNames[i] != null) {
      if (imageNames[i].startsWith(thePrefix)) {
        indexes = append(indexes, i);
      }
    }
  }

  CollageItem[] items = new CollageItem[theCount];
  for (int i = 0 ; i < items.length; i++) {
    items[i] = new CollageItem();
    items[i].indexToImage = indexes[i%indexes.length];
    items[i].x = thePosX + random(-theRangeX/2,theRangeX/2);
    items[i].y = thePosY + random(-theRangeY/2,theRangeY/2);
    items[i].scaling = random(theScaleStart,theScaleEnd);
    items[i].rotation = random(therotationStart,therotationEnd);
  }
  return items;
}


void drawCollageItems(CollageItem[] theItems) {
  for (int i = 0 ; i < theItems.length; i++) {
    pushMatrix();
    translate(theItems[i].x, theItems[i].y);
    rotate(theItems[i].rotation);
    scale(theItems[i].scaling);
    image(images[theItems[i].indexToImage], 0,0);
    popMatrix();
  }
}


// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}