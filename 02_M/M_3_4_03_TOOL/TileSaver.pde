// M_3_4_01_TOOL.pde
// GUI.pde, Mesh.pde, TileSaver.pde
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

// TileSaver.pde - v0.12 2007.0326
// Marius Watz - http://workshop.evolutionzone.com
//
// Class for rendering high-resolution images by splitting them into
// tiles using the viewport.
//
// Builds heavily on solution by "surelyyoujest":
// http://processing.org/discourse/yabb_beta/YaBB.cgi?
// board=OpenGL;action=display;num=1159148942

class TileSaver {
  public boolean isTiling=false,done=true;
  public boolean doSavePreview=false;

  PApplet p;
  float FOV=60; // initial field of view
  float cameraZ, width, height;
  int tileNum=10,tileNumSq; // number of tiles
  int tileImgCnt, tileX, tileY, tilePad;
  boolean firstFrame=false, secondFrame=false;
  String tileFilename,tileFileextension=".png";
  PImage tileImg;
  float perc,percMilestone;

  // The constructor takes a PApplet reference to your sketch.
  public TileSaver(PApplet _p) {
    p=_p;
  }

  // If init() is called without specifying number of tiles, getMaxTiles()
  // will be called to estimate number of tiles according to free memory.
  public void init(String _filename) {
    init(_filename,getMaxTiles(p.width));
  }

  // Initialize using a filename to output to and number of tiles to use.
  public void init(String _filename,int _num) {
    tileFilename=_filename;
    tileNum=_num;
    tileNumSq=(tileNum*tileNum);

    // Reset tile counters to start over correctly
    tileX = 0;
    tileY = 0;
    
    width=p.width;
    height=p.height;
    cameraZ=(height/2.0f)/p.tan(p.PI*FOV/360.0f);
    p.println("TileSaver: "+tileNum+" tilesnResolution: "+
      (p.width*tileNum)+"x"+(p.height*tileNum));

    // remove extension from filename
    if(!new java.io.File(tileFilename).isAbsolute())
      tileFilename=p.sketchPath(tileFilename);
    tileFilename=noExt(tileFilename);
    p.createPath(tileFilename);

    // save preview
    if(doSavePreview) p.g.save(tileFilename+"_preview.png");

    // set up off-screen buffer for saving tiled images
    tileImg=new PImage(p.width*tileNum, p.height*tileNum);

    // start tiling
    done=false;
    isTiling=false;
    perc=0;
    percMilestone=0;
    tileInc();
  }

  // set filetype, default is TGA. pass a valid image extension as parameter.
  public void setSaveType(String extension) {
    tileFileextension=extension;
    if(tileFileextension.indexOf(".")==-1) tileFileextension="."+tileFileextension;
  }

  // pre() handles initialization of each frame.
  // It should be called in draw() before any drawing occurs.
  public void pre() {
    if(!isTiling) return;
    if(firstFrame) firstFrame=false;
    else if(secondFrame) {
      secondFrame=false;
      
      // since processing version 1.0.8 (revision 0170) the following line has to be removed,
      //        because updating of the projection works now imediately.
      // tileInc();
    }
    setupCamera();
  }

  // post() handles tile update and image saving.
  // It should be called at the very end of draw(), after any drawing.
  public void post() {
    // If first or second frame, don't update or save.
    if(firstFrame||secondFrame|| (!isTiling)) return;

    // Find image ID from reverse row order
    int imgid=tileImgCnt%tileNum+(tileNum-tileImgCnt/tileNum-1)*tileNum;
    int idx=(imgid+0)%tileNum;
    int idy=(imgid/tileNum);

    // Get current image from sketch and draw it into buffer
    p.loadPixels();
    tileImg.set(idx*p.width, idy*p.height, p.g);

    // Increment tile index
    tileImgCnt++;
    perc=100*((float)tileImgCnt/(float)tileNumSq);
    if(perc-percMilestone>5 || perc>99) {
      p.println(p.nf(perc,3,2)+"% completed. "+tileImgCnt+"/"+tileNumSq+" images saved.");
      percMilestone=perc;
    }

    if(tileImgCnt==tileNumSq) tileFinish();
    else tileInc();
  }

  public boolean checkStatus() {
    return isTiling;
  }


  // tileFinish() handles saving of the tiled image
  public void tileFinish() {
    isTiling=false;

    restoreCamera();

    // save large image to TGA
    tileFilename+="_"+(p.width*tileNum)+"x"+
      (p.height*tileNum)+tileFileextension;
    p.println("Save: "+
      tileFilename.substring(
    tileFilename.lastIndexOf(java.io.File.separator)+1));
    tileImg.save(tileFilename);
    p.println("Done tiling.n");

    // clear buffer for garbage collection
    tileImg=null;
    done=true;
  }

  // Increment tile coordinates
  public void tileInc() {
    if(!isTiling) {
      isTiling=true;
      firstFrame=true;
      secondFrame=true;
      tileImgCnt=0;
    } 
    else {
      if(tileX==tileNum-1) {
        tileX=0;
        tileY=(tileY+1)%tileNum;
      } 
      else
        tileX++;
    }
  }

  // set up camera correctly for the current tile
  public void setupCamera() {
    p.camera(width/2.0f, height/2.0f, cameraZ,
    width/2.0f, height/2.0f, 0, 0, 1, 0);
    if(isTiling) {
      float mod=1f/10f;
      p.frustum(width*((float)tileX/(float)tileNum-.5f)*mod,
      width*((tileX+1)/(float)tileNum-.5f)*mod,
      height*((float)tileY/(float)tileNum-.5f)*mod,
      height*((tileY+1)/(float)tileNum-.5f)*mod,
      cameraZ*mod, 10000);
    }

  }

  // restore camera once tiling is done
  public void restoreCamera() {
    float mod=1f/10f;
    p.camera(width/2.0f, height/2.0f, cameraZ,
    width/2.0f, height/2.0f, 0, 0, 1, 0);
    p.frustum(-(width/2)*mod, (width/2)*mod,
    -(height/2)*mod, (height/2)*mod,
    cameraZ*mod, 10000);
  }

  // checks free memory and gives a suggestion for maximum tile
  // resolution. It should work well in most cases, I've been able
  // to generate 20k x 20k pixel images with 1.5 GB RAM allocated.
  public int getMaxTiles(int width) {

    // get an instance of java.lang.Runtime, force garbage collection
    java.lang.Runtime runtime=java.lang.Runtime.getRuntime();
    runtime.gc();

    // calculate free memory for ARGB (4 byte) data, giving some slack
    // to out of memory crashes.
    int num=(int)(Math.sqrt(
    (float)(runtime.freeMemory()/4)*0.925f))/width;
    p.println(((float)runtime.freeMemory()/(1024*1024))+"/"+
      ((float)runtime.totalMemory()/(1024*1024)));

    // warn if low memory
    if(num==1) {
      p.println("Memory is low. Consider increasing memory settings.");
      num=2;
    }

    return num;
  }

  // strip extension from filename
  String noExt(String name) {
    int last=name.lastIndexOf(".");
    if(last>0)
      return name.substring(0, last);

    return name;
  }
}