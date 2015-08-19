// M_4_2_01.pde
// Attractor.pde
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

class Attractor {
  // position
  float x=0, y=0; 

  // radius of impact
  float radius = 200;


  Attractor(float theX, float theY) {
    x = theX;
    y = theY;
  }


  void attract(Node theNode) {
    // calculate distance
    float dx = x - theNode.x;
    float dy = y - theNode.y;
    float d = mag(dx, dy);

    if (d > 0 && d < radius) {
      // calculate force
      float s = d/radius;
      float f = 1 / pow(s, 0.5) - 1;
      f = f / radius;
      
      // apply force to node velocity
      theNode.velocity.x += dx * f;
      theNode.velocity.y += dy * f;
    }
  }

}







