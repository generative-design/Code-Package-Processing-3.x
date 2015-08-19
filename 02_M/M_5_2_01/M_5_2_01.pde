// M_5_2_01.pde
// FileSystemItem.pde
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

// CREDITS
// part of the FileSystemItem class is based on code from Visualizing Data, First Edition 
// by Ben Fry. Copyright 2008 Ben Fry, 9780596514556.

/**
 * press 'o' to select an input folder!
 * console output only!
 * take care of very big folders, loading will take up to several minutes.
 * 
 * program takes a file directory (hierarchical tree) on harddisk 
 * as input and prints all filenames to the console.
 *
 * and shows also how to traverse a hierarchical tree in two
 * different ways: Depth First Search + Breadth First Search
 * 
 * KEYS
 * o                  : select an input folder
 */

import java.util.Calendar;
import java.io.File;

// ------ default folder path ------
String defaultFolderPath = System.getProperty("user.home")+"/Desktop";
//String defaultFolderPath = "/Users/admin/Desktop";
//String defaultFolderPath = "C:\\windows";

// ------ program logic ------
int fileCounter = 0;

void setup() {
  size(128,128);
  setInputFolder(defaultFolderPath);
}

void draw() {
  // keep the app running
}

// ------ folder selection dialog + init visualization ------
void setInputFolder(File theFolder) {
  setInputFolder(theFolder.toString());
}

void setInputFolder(String theFolderPath) {
  // get files on harddisk
  println("\n"+theFolderPath);
  FileSystemItem selectedFolder = new FileSystemItem(new File(theFolderPath)); 
  selectedFolder.printDepthFirst();
  println("\n");
  selectedFolder.printBreadthFirst(); 
}

void keyReleased() {
  if (key == 'o' || key == 'O') {
    selectFolder("please select a folder", "setInputFolder");
  }
}



