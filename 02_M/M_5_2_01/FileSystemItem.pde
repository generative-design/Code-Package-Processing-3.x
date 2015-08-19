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

// This class code is based on code and ideas of chapter 7 in
// Visualizing Data, First Edition by Ben Fry. Copyright 2008 Ben Fry, 9780596514556.

class FileSystemItem {
  File file;
  FileSystemItem[] children;
  int childCount;

  // ------ constructor ------
  FileSystemItem(File theFile) {
    file = theFile;

    if (file.isDirectory()) {
      String[] contents = file.list();
      if (contents != null) {
        // Sort the file names in case insensitive order
        contents = sort(contents);

        children = new FileSystemItem[contents.length];
        for (int i = 0 ; i < contents.length; i++) {
          // skip the . and .. directory entries on Unix systems
          if (contents[i].equals(".") || contents[i].equals("..")
            || contents[i].substring(0,1).equals(".")) {
            continue;
          }
          File childFile = new File(file, contents[i]);
          // skip any file that appears to be a symbolic link
          try {
            String absPath = childFile.getAbsolutePath();
            String canPath = childFile.getCanonicalPath();
            if (!absPath.equals(canPath)) continue;
          } 
          catch (IOException e) { 
          }
          FileSystemItem child = new FileSystemItem(childFile);
          children[childCount] = child;
          childCount++;
        }
      }
    }
  }



  // ------ print and debug functions ------
  // Depth First Search
  void printDepthFirst() {
    println("printDepthFirst");
    // global fileCounter
    fileCounter = 0;
    printDepthFirst(0,-1);
    println(fileCounter+" files");
  }
  void printDepthFirst(int depth, int indexToParent) {
    // print four spaces for each level of depth + debug println
    for (int i = 0; i < depth; i++) print("    ");  
    println(fileCounter+" "+indexToParent+"<-->"+fileCounter+" ("+depth+") "+file.getName());

    indexToParent = fileCounter;
    fileCounter++;
    // now handle the children, if any
    for (int i = 0; i < childCount; i++) {
      children[i].printDepthFirst(depth+1,indexToParent);
    }
  }


  // Breadth First Search
  void printBreadthFirst() {
    println("printBreadthFirst");

    // queues for pushing and saving all elements in "breadth first search" style
    ArrayList items = new ArrayList();  
    ArrayList depths = new ArrayList(); 
    ArrayList indicesParent = new ArrayList(); 

    // add first elements and startingpoint
    items.add(this);
    depths.add(0);
    indicesParent.add(-1);

    // tmp vars for running in while loop
    int index = 0;
    int itemCount = 1;

    while (itemCount > index) {
      FileSystemItem item = (FileSystemItem) items.get(index);
      int depth = (Integer) depths.get(index); 
      int indexToParent = (Integer) indicesParent.get(index);

      // print four spaces for each level of depth + debug println
      for (int i = 0; i < depth; i++) print("    ");
      println(index+" "+indexToParent+"<-->"+index+" ("+depth+") "+item.file.getName());

      // is current node a directory?
      // yes -> push all children to the end of the items
      if (item.file.isDirectory()) {      
        for (int i = 0; i < item.childCount; i++) {
          items.add(item.children[i]);  
          depths.add(depth+1);
          indicesParent.add(index);    
        }
        itemCount += item.childCount;
      }
      index++;
    }
    println(index+" files");
  }
}




































