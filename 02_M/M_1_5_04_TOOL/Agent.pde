// M_1_5_04_TOOL.pde
// Agent.pde, GUI.pde
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

class Agent {
  PVector p, pOld;
  float zNoise, zNoiseVelocity = 0.01;
  float stepSize, angle, randomizer;
  color col;

  Agent() {
    p = new PVector(random(width),random(height));
    pOld = new PVector(p.x,p.y);
    randomizer = random(1);
    stepSize = 1+randomizer*4;
    
    // colors
    if (randomizer < 0.5) col = color((int)random(170,190), 70, (int)random(0,100));
    else col = color((int)random(40,60), 70, (int)random(0,100));
    
    // init zNoise
    setNoiseSticking(0.4);
  }

  void update1(){
    angle = noise(p.x/noiseScale,p.y/noiseScale,zNoise) * noiseStrength;

    p.x += cos(angle) * stepSize;
    p.y += sin(angle) * stepSize;

    // offscreen wrap
    if(p.x<-10) p.x=pOld.x=width+10;
    if(p.x>width+10) p.x=pOld.x=-10;
    if(p.y<-10) p.y=pOld.y=height+10;
    if(p.y>height+10) p.y=pOld.y=-10;
    
    stroke(col, agentsAlpha);
    strokeWeight(strokeWidth);
    line(pOld.x,pOld.y, p.x,p.y);
    
    float agentWidth = map(randomizer,0,1,agentWidthMin,agentWidthMax);
    pushMatrix();
    translate(pOld.x,pOld.y);    
    rotate(atan2(p.y-pOld.y,p.x-pOld.x));
    line(0,-agentWidth,0,agentWidth);
    popMatrix();

    pOld.set(p);
    zNoise += zNoiseVelocity;
  }

  void update2(){
    angle = noise(p.x/noiseScale,p.y/noiseScale,zNoise) * noiseStrength;

    p.x += cos(angle) * stepSize;
    p.y += sin(angle) * stepSize;

    // offscreen wrap
    if(p.x<-10) p.x=pOld.x=width+10;
    if(p.x>width+10) p.x=pOld.x=-10;
    if(p.y<-10) p.y=pOld.y=height+10;
    if(p.y>height+10) p.y=pOld.y=-10;

    stroke(col);
    strokeWeight(2);
    float agentWidth = map(randomizer,0,1,agentWidthMin,agentWidthMax)*2;   
    ellipse(pOld.x,pOld.y,agentWidth,agentWidth);

    pOld.set(p);
    zNoise += zNoiseVelocity;
  }


  void setNoiseSticking(float stickingRange) {
    // small values will increase stinking of the agents
    zNoise = random(stickingRange);
  }
}









