// M_3_3_03.pde
// Mesh.pde
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


class Mesh {

  // ------ constants ------

  final static int PLANE              = CUSTOM;
  final static int TUBE               = 1;
  final static int SPHERE             = 2;
  final static int TORUS              = 3;
  final static int PARABOLOID         = 4;
  final static int STEINBACHSCREW     = 5;
  final static int SINE               = 6;
  final static int FIGURE8TORUS       = 7;
  final static int ELLIPTICTORUS      = 8;
  final static int CORKSCREW          = 9;
  final static int BOHEMIANDOME       = 10;
  final static int BOW                = 11;
  final static int MAEDERSOWL         = 12;
  final static int ASTROIDALELLIPSOID = 13;
  final static int TRIAXIALTRITORUS   = 14;
  final static int LIMPETTORUS        = 15;
  final static int HORN               = 16;
  final static int SHELL              = 17;
  final static int KIDNEY             = 18;
  final static int LEMNISCAPE         = 19;
  final static int TRIANGULOID         = 20;
  final static int SUPERFORMULA       = 21;


  // ------ mesh parameters ------

  int form = PARABOLOID;

  float uMin = -PI;
  float uMax = PI;
  int uCount = 50;

  float vMin = -PI;
  float vMax = PI;
  int vCount = 50;

  float[] params = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1        };

  int drawMode = TRIANGLE_STRIP;
  float minHue = 0;
  float maxHue = 0;
  float minSaturation = 0;
  float maxSaturation = 0;
  float minBrightness = 50;
  float maxBrightness = 50;
  float meshAlpha = 100;

  float meshDistortion = 0;

  PVector[][] points;


  // ------ construktors ------

  Mesh() {
    form = CUSTOM;
    update();
  }

  Mesh(int theForm) {
    if (theForm >=0) {
      form = theForm;
    }
    update();
  }

  Mesh(int theForm, int theUNum, int theVNum) {
    if (theForm >=0) {
      form = theForm;
    }
    uCount = max(theUNum, 1);
    vCount = max(theVNum, 1);
    update();
  }

  Mesh(int theForm, float theUMin, float theUMax, float theVMin, float theVMax) {
    if (theForm >=0) {
      form = theForm;
    }
    uMin = theUMin;    
    uMax = theUMax;    
    vMin = theVMin;    
    vMax = theVMax;    
    update();
  }

  Mesh(int theForm, int theUNum, int theVNum, float theUMin, float theUMax, float theVMin, float theVMax) {
    if (theForm >=0) {
      form = theForm;
    }
    uCount = max(theUNum, 1);
    vCount = max(theVNum, 1);
    uMin = theUMin;    
    uMax = theUMax;    
    vMin = theVMin;    
    vMax = theVMax;    
    update();
  }



  // ------ calculate points ------

  void update() {
    points = new PVector[vCount+1][uCount+1];

    float u, v;
    for (int iv = 0; iv <= vCount; iv++) {
      for (int iu = 0; iu <= uCount; iu++) {
        u = map(iu, 0, uCount, uMin, uMax);
        v = map(iv, 0, vCount, vMin, vMax);

        switch(form) {
        case CUSTOM: 
          points[iv][iu] = calculatePoints(u, v);
          break;
        case TUBE: 
          points[iv][iu] = Tube(u, v);
          break;
        case SPHERE: 
          points[iv][iu] = Sphere(u, v);
          break;
        case TORUS: 
          points[iv][iu] = Torus(u, v);
          break;
        case PARABOLOID: 
          points[iv][iu] = Paraboloid(u, v);
          break;
        case STEINBACHSCREW: 
          points[iv][iu] = SteinbachScrew(u, v);
          break;
        case SINE: 
          points[iv][iu] = Sine(u, v);
          break;
        case FIGURE8TORUS: 
          points[iv][iu] = Figure8Torus(u, v);
          break;
        case ELLIPTICTORUS: 
          points[iv][iu] = EllipticTorus(u, v);
          break;
        case CORKSCREW: 
          points[iv][iu] = Corkscrew(u, v);
          break;
        case BOHEMIANDOME: 
          points[iv][iu] = BohemianDome(u, v);
          break;
        case BOW: 
          points[iv][iu] = Bow(u, v);
          break;
        case MAEDERSOWL: 
          points[iv][iu] = MaedersOwl(u, v);
          break;
        case ASTROIDALELLIPSOID: 
          points[iv][iu] = AstroidalEllipsoid(u, v);
          break;
        case TRIAXIALTRITORUS: 
          points[iv][iu] = TriaxialTritorus(u, v);
          break;
        case LIMPETTORUS: 
          points[iv][iu] = LimpetTorus(u, v);
          break;
        case HORN: 
          points[iv][iu] = Horn(u, v);
          break;
        case SHELL: 
          points[iv][iu] = Shell(u, v);
          break;
        case KIDNEY: 
          points[iv][iu] = Kidney(u, v);
          break;
        case LEMNISCAPE: 
          points[iv][iu] = Lemniscape(u, v);
          break;
        case TRIANGULOID: 
          points[iv][iu] = Trianguloid(u, v);
          break;
        case SUPERFORMULA: 
          points[iv][iu] = Superformula(u, v);
          break;

        default:
          points[iv][iu] = calculatePoints(u, v);
          break;          
        }
      }
    }
  }


  // ------ getters and setters ------

  int getForm() {
    return form;
  }
  void setForm(int theValue) {
    form = theValue;
  }

  String getFormName() {
    switch(form) {
    case CUSTOM: 
      return "Custom";
    case TUBE: 
      return "Tube";
    case SPHERE: 
      return "Sphere";
    case TORUS: 
      return "Torus";
    case PARABOLOID: 
      return "Paraboloid";
    case STEINBACHSCREW: 
      return "Steinbach Screw";
    case SINE: 
      return "Sine";
    case FIGURE8TORUS: 
      return "Figure 8 Torus";
    case ELLIPTICTORUS: 
      return "Elliptic Torus";
    case CORKSCREW: 
      return "Corkscrew";
    case BOHEMIANDOME: 
      return "Bohemian Dome";
    case BOW: 
      return "Bow";
    case MAEDERSOWL: 
      return "Maeders Owl";
    case ASTROIDALELLIPSOID: 
      return "Astoidal Ellipsoid";
    case TRIAXIALTRITORUS: 
      return "Triaxial Tritorus";
    case LIMPETTORUS: 
      return "Limpet Torus";
    case HORN: 
      return "Horn";
    case SHELL: 
      return "Shell";
    case KIDNEY: 
      return "Kidney";
    case LEMNISCAPE: 
      return "Lemniscape";
    case TRIANGULOID: 
      return "Trianguloid";
    case SUPERFORMULA: 
      return "Superformula";
    }
    return "";
  }

  float getUMin() {
    return uMin;
  }
  void setUMin(float theValue) {
    uMin = theValue;
  }

  float getUMax() {
    return uMax;
  }
  void setUMax(float theValue) {
    uMax = theValue;
  }

  int getUCount() {
    return uCount;
  }
  void setUCount(int theValue) {
    uCount = theValue;
  }

  float getVMin() {
    return vMin;
  }
  void setVMin(float theValue) {
    vMin = theValue;
  }

  float getVMax() {
    return vMax;
  }
  void setVMax(float theValue) {
    vMax = theValue;
  }

  int getVCount() {
    return vCount;
  }
  void setVCount(int theValue) {
    vCount = theValue;
  }

  float[] getParams() {
    return params;
  }
  void setParams(float[] theValues) {
    params = theValues;
  }

  float getParam(int theIndex) {
    return params[theIndex];
  }
  void setParam(int theIndex, float theValue) {
    params[theIndex] = theValue;
  }

  int getDrawMode() {
    return drawMode;
  }
  void setDrawMode(int theMode) {
    drawMode = theMode;
  }

  float getMeshDistortion() {
    return meshDistortion;
  }
  void setMeshDistortion(float theValue) {
    meshDistortion = theValue;
  }

  void setColorRange(float theMinHue, float theMaxHue, float theMinSaturation, float theMaxSaturation, float theMinBrightness, float theMaxBrightness, float theMeshAlpha) {
    minHue = theMinHue;
    maxHue = theMaxHue;
    minSaturation = theMinSaturation;
    maxSaturation = theMaxSaturation;
    minBrightness = theMinBrightness;
    maxBrightness = theMaxBrightness;
    meshAlpha = theMeshAlpha;
  }

  float getMinHue() {
    return minHue;
  }
  void setMinHue(float minHue) {
    this.minHue = minHue;
  }

  float getMaxHue() {
    return maxHue;
  }
  void setMaxHue(float maxHue) {
    this.maxHue = maxHue;
  }

  float getMinSaturation() {
    return minSaturation;
  }
  void setMinSaturation(float minSaturation) {
    this.minSaturation = minSaturation;
  }

  float getMaxSaturation() {
    return maxSaturation;
  }
  void setMaxSaturation(float maxSaturation) {
    this.maxSaturation = maxSaturation;
  }

  float getMinBrightness() {
    return minBrightness;
  }
  void setMinBrightness(float minBrightness) {
    this.minBrightness = minBrightness;
  }

  float getMaxBrightness() {
    return maxBrightness;
  }
  void setMaxBrightness(float maxBrightness) {
    this.maxBrightness = maxBrightness;
  }

  float getMeshAlpha() {
    return meshAlpha;
  }
  void setMeshAlpha(float meshAlpha) {
    this.meshAlpha = meshAlpha;
  }


  // ------ functions for calculating the mesh points ------

  PVector calculatePoints(float u, float v) {
    float x = u;
    float y = v;
    float z = 0;

    return new PVector(x, y, z);
  }

  PVector defaultForm(float u, float v) {
    float x = u;
    float y = v;
    float z = 0;

    return new PVector(x, y, z);
  }

  PVector Tube(float u, float v) {
    float x = (sin(u));
    float y = params[0] * v;
    float z = (cos(u));

    return new PVector(x, y, z);
  }

  PVector Sphere(float u, float v) {
    v /= 2;
    v += HALF_PI;
    float x = 2 * (sin(v) * sin(u));
    float y = 2 * (params[0] * cos(v));
    float z = 2 * (sin(v) * cos(u));

    return new PVector(x, y, z);
  }

  PVector Torus(float u, float v) {
    float x = 1 * ((params[1] + 1 + params[0] * cos(v)) * sin(u));
    float y = 1 * (params[0] * sin(v));
    float z = 1 * ((params[1] + 1 + params[0] * cos(v)) * cos(u));

    return new PVector(x, y, z);
  }

  PVector Paraboloid(float u, float v) {
    float pd = params[0]; 
    if (pd == 0) {
      pd = 0.0001; 
    }
    float x = power((v/pd),0.5) * sin(u);
    float y = v;
    float z = power((v/pd),0.5) * cos(u);

    return new PVector(x, y, z);
  }


  PVector SteinbachScrew(float u, float v) {
    float x = u * cos(v);
    float y = u * sin(params[0] * v);
    float z = v * cos(u);

    return new PVector(x, y, z);
  }

  PVector Sine(float u, float v) {
    float x = 2 * sin(u);
    float y = 2 * sin(params[0] * v);
    float z = 2 * sin(u+v);

    return new PVector(x, y, z);
  }


  PVector Figure8Torus(float u, float v) {
    float x = 1.5 * cos(u) * (params[0] + sin(v) * cos(u) - sin(2*v) * sin(u) / 2);
    float y = 1.5 * sin(u) * (params[0] + sin(v) * cos(u) - sin(2*v) * sin(u) / 2) ;
    float z = 1.5 * sin(u) * sin(v) + cos(u) * sin(2*v) / 2;

    return new PVector(x, y, z);
  }

  PVector EllipticTorus(float u, float v) {
    float x = 1.5 * (params[0] + cos(v)) * cos(u);
    float y = 1.5 * (params[0] + cos(v)) * sin(u) ;
    float z = 1.5 * sin(v) + cos(v);

    return new PVector(x, y, z);
  }

  PVector Corkscrew(float u, float v) {
    float x = cos(u) * cos(v);
    float y = sin(u) * cos(v);
    float z = sin(v) + params[0] * u;

    return new PVector(x, y, z);
  }

  PVector BohemianDome(float u, float v) {
    float x = 2 * cos(u);
    float y = 2 * sin(u) + params[0] * cos(v);
    float z = 2 * sin(v);

    return new PVector(x, y, z);
  }

  PVector Bow(float u, float v) {
    u /= TWO_PI;
    v /= TWO_PI;
    float x = (2 + params[0] * sin(TWO_PI * u)) * sin(2 * TWO_PI * v);
    float y = (2 + params[0] * sin(TWO_PI * u)) * cos(2 * TWO_PI * v);
    float z = params[0] * cos(TWO_PI * u) + 3 * cos(TWO_PI * v);

    return new PVector(x, y, z);
  }

  PVector MaedersOwl(float u, float v) {
    float x = 0.4 * (v * cos(u) - 0.5*params[0] * power(v,2) * cos(2 * u));
    float y = 0.4 * (-v * sin(u) - 0.5*params[0] * power(v,2) * sin(2 * u));
    float z = 0.4 * (4 * power(v,1.5) * cos(3 * u / 2) / 3);

    return new PVector(x, y, z);
  }

  PVector AstroidalEllipsoid(float u, float v) {
    u /= 2;
    float x = 3 * power(cos(u)*cos(v),3*params[0]);
    float y = 3 * power(sin(u)*cos(v),3*params[0]);
    float z = 3 * power(sin(v),3*params[0]);

    return new PVector(x, y, z);
  }

  PVector TriaxialTritorus(float u, float v) {
    float x = 1.5 * sin(u) * (1 + cos(v));
    float y = 1.5 * sin(u + TWO_PI / 3 * params[0]) * (1 + cos(v + TWO_PI / 3 * params[0]));
    float z = 1.5 * sin(u + 2*TWO_PI / 3 * params[0]) * (1 + cos(v + 2*TWO_PI / 3 * params[0]));

    return new PVector(x, y, z);
  }

  PVector LimpetTorus(float u, float v) {
    float x = 1.5 * params[0] * cos(u) / (sqrt(2) + sin(v));
    float y = 1.5 * params[0] * sin(u) / (sqrt(2) + sin(v));
    float z = 1.5 * 1 / (sqrt(2) + cos(v));

    return new PVector(x, y, z);
  }

  PVector Horn(float u, float v) {
    u /= PI;
    //v /= PI;
    float x = (2*params[0] + u * cos(v)) * sin(TWO_PI * u);
    float y = (2*params[0] + u * cos(v)) * cos(TWO_PI * u) + 2 * u;
    float z = u * sin(v);

    return new PVector(x, y, z);
  }

  PVector Shell(float u, float v) {
    float x = params[1] * (1 - (u / TWO_PI)) * cos(params[0]*u) * (1 + cos(v)) + params[3] * cos(params[0]*u);
    float y = params[1] * (1 - (u / TWO_PI)) * sin(params[0]*u) * (1 + cos(v)) + params[3] * sin(params[0]*u);
    float z = params[2] * (u / TWO_PI) + params[0] * (1 - (u / TWO_PI)) * sin(v);

    return new PVector(x, y, z);
  }

  PVector Kidney(float u, float v) {
    u /= 2;
    float x = cos(u) * (params[0]*3*cos(v) - cos(3*v));
    float y = sin(u) * (params[0]*3*cos(v) - cos(3*v));
    float z = 3 * sin(v) - sin(3*v);

    return new PVector(x, y, z);
  }

  PVector Lemniscape(float u, float v) {
    u /= 2;
    float cosvSqrtAbsSin2u = cos(v)*sqrt(abs(sin(2*params[0]*u)));
    float x = cosvSqrtAbsSin2u*cos(u);
    float y = cosvSqrtAbsSin2u*sin(u);
    float z = 3 * (power(x,2) - power(y,2) + 2 * x * y * power(tan(v),2));
    x *= 3;
    y *= 3;
    return new PVector(x, y, z);
  }

  PVector Trianguloid(float u, float v) {
    float x = 0.75 * (sin(3*u) * 2 / (2 + cos(v)));
    float y = 0.75 * ((sin(u) + 2 * params[0] * sin(2*u)) * 2 / (2 + cos(v + TWO_PI)));
    float z = 0.75 * ((cos(u) - 2 * params[0] * cos(2*u)) * (2 + cos(v)) * ((2 + cos(v + TWO_PI/3))*0.25));

    return new PVector(x, y, z);
  }

  PVector Superformula(float u, float v) {
    v /= 2;

    // Superformel 1
    float a = params[0];
    float b = params[1];
    float m = (params[2]);
    float n1 = (params[3]);
    float n2 = (params[4]);
    float n3 = (params[5]);
    float r1 = pow(pow(abs(cos(m*u/4)/a), n2) + pow(abs(sin(m*u/4)/b), n3), -1/n1);

    // Superformel 2
    a = params[6];
    b = params[7];
    m = (params[8]);
    n1 = (params[9]);
    n2 = (params[10]);
    n3 = (params[11]);
    float r2 = pow(pow(abs(cos(m*v/4)/a), n2) + pow(abs(sin(m*v/4)/b), n3), -1/n1);

    float x = 2 * (r1*sin(u) * r2*cos(v));
    float y = 2 * (r2*sin(v));
    float z = 2 * (r1*cos(u) * r2*cos(v));

    return new PVector(x, y, z);
  }




  // ------ definition of some mathematical functions ------

  // the processing-function pow works a bit differently for negative bases
  float power(float b, float e) {
    if (b >= 0 || int(e) == e) {
      return pow(b, e);
    } 
    else {
      return -pow(-b, e);
    }
  }

  float logE(float v) {
    if (v >= 0) {
      return log(v);
    } 
    else{
      return -log(-v);
    }
  }

  float sinh(float a) {
    return (sin(HALF_PI/2-a));
  }

  float cosh(float a) {
    return (cos(HALF_PI/2-a));
  }

  float tanh(float a) {
    return (tan(HALF_PI/2-a));
  }



  // ------ draw mesh ------

  void draw() {
    int iuMax, ivMax;

    if (drawMode == QUADS || drawMode == TRIANGLES) {
      iuMax = uCount-1;
      ivMax = vCount-1;
    }
    else{
      iuMax = uCount;
      ivMax = vCount-1;
    }

    // store previously set colorMode
    pushStyle();
    colorMode(HSB, 360, 100, 100, 100);

    float minH = minHue;
    float maxH = maxHue;
    if (abs(maxH-minH) < 20) maxH = minH;
    float minS = minSaturation;
    float maxS = maxSaturation;
    if (abs(maxS-minS) < 10) maxS = minS;
    float minB = minBrightness;
    float maxB = maxBrightness;
    if (abs(maxB-minB) < 10) maxB = minB;


    for (int iv = 0; iv <= ivMax; iv++) {
      if (drawMode == TRIANGLES) {

        for (int iu = 0; iu <= iuMax; iu++) {
          fill(random(minH, maxH), random(minS, maxS), random(minB, maxB), meshAlpha);
          beginShape(drawMode);
          float r1 = meshDistortion * random(-1, 1);
          float r2 = meshDistortion * random(-1, 1);
          float r3 = meshDistortion * random(-1, 1);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
          endShape();

          fill(random(minH, maxH), random(minS, maxS), random(minB, maxB), meshAlpha);
          beginShape(drawMode);
          r1 = meshDistortion * random(-1, 1);
          r2 = meshDistortion * random(-1, 1);
          r3 = meshDistortion * random(-1, 1);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv][iu+1].x+r1, points[iv][iu+1].y+r2, points[iv][iu+1].z+r3);
          endShape();
        }       

      }
      else if (drawMode == QUADS) {
        for (int iu = 0; iu <= iuMax; iu++) {
          fill(random(minH, maxH), random(minS, maxS), random(minB, maxB), meshAlpha);
          beginShape(drawMode);

          float r1 = meshDistortion * random(-1, 1);
          float r2 = meshDistortion * random(-1, 1);
          float r3 = meshDistortion * random(-1, 1);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv][iu+1].x+r1, points[iv][iu+1].y+r2, points[iv][iu+1].z+r3);

          endShape();
        }        
      }
      else{
        // Draw Strips
        fill(random(minH, maxH), random(minS, maxS), random(minB, maxB), meshAlpha);
        beginShape(drawMode);

        for (int iu = 0; iu <= iuMax; iu++) {
          float r1 = meshDistortion * random(-1, 1);
          float r2 = meshDistortion * random(-1, 1);
          float r3 = meshDistortion * random(-1, 1);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
        }  

        endShape();
      }
    }

    popStyle();
  }

}


