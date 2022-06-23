//Object to keep track of a triangles verticies and its projected screen verticies
class Triangle {
  Triangle(float[] V1, float[] V2, float[] V3) {
    v1 = Arrays.copyOf(V1, V1.length); 
    v2 = Arrays.copyOf(V2, V2.length);
    v3 = Arrays.copyOf(V3, V3.length);
    updateAll();
  }

  // positions of three triangle vertices in 3D space
  float[] v1;
  float[] v2;
  float[] v3;
  
  // three vertices projected onto 2D raster space
  float[] pv1;
  float[] pv2;
  float[] pv3;
  
  // copy in a new set of 3D vertices
  void setVertices(float[] newV1, float[] newV2, float[] newV3) {
    System.arraycopy(newV1, 0, v1, 0, newV1.length);
    System.arraycopy(newV2, 0, v2, 0, newV2.length);
    System.arraycopy(newV3, 0, v3, 0, newV3.length);
    updateAll();
  }

  // if triangle vertices change, update remaining data
  void updateAll() {
    pv1 = projectVertex(v1);
    pv2 = projectVertex(v2);
    pv3 = projectVertex(v3);    
  }
  
  // rotate triangle by given angle
  void rotate(float theta) {
    rotateVertex(v1, theta);
    rotateVertex(v2, theta);
    rotateVertex(v3, theta);
    updateAll();
  }
}

//use these lists for the original and rotated triangles that tesselate the cube
Triangle[] cubeList;
Triangle[] rotatedList;

PGraphics buffer;

void setup() {
  colorMode(RGB, 1.0f);  // set RGB to 0..1 instead of 0..255

  buffer = createGraphics(600, 600);
  
  printSettings();
}

void settings() {
  size(600, 600); // hard-coded canvas size, same as the buffer
}

// used to make the image rotate - don't change these values
float theta = 0;  // rotation angle
float dtheta = 0.01; // rotation speed

//Draws the cube to the raster
void draw() {
  buffer.beginDraw();
  buffer.colorMode(RGB, 1.0f);
  buffer.background(0); // clear to black each frame
  
  buffer.loadPixels();

  if (doRotate)
  {
    theta += dtheta;
    if (theta > TWO_PI) theta -= TWO_PI;
  } 

  //Creates cube at the current angle and rotation
  makeCube(CUBE_SIZE, CUBE_DIVISIONS);
  rotateTriangles(cubeList, rotatedList, theta); // copy your triangle list, rotate it, and store in rotatedList
  drawTriangles(rotatedList);  // draw the list of rotated triangles

  buffer.updatePixels();
  buffer.endDraw(); // clean up the buffer before drawing / flush buffers
  image(buffer, 0, 0); // draw our raster image on the screen
}


/*
Creates and returns the list of triangles that tessellates a cube of the given
side length that is centered on (0,0,0). The triangles are right triangles whose
legs (perpendicular sides) lie along or are parallel to the edges of the cube.
The parameter divisions is the number of triangles that lie along *each* edge 
on *each* face of the cube.  For example:
divisions = 1 --> 1 triangle per edge
              --> 2 triangles per face (draw this on paper if it isn't clear)
              --> 2x6=12 triangles total
*/
Triangle[] makeCube(int size, int divisions) {
  //3d array to hold points, the current face being looked at is the first parameter:
  //    0 = Front
  //    1 = Back
  //    2 = Left 
  //    3 = Right
  //    4 = Top
  //    5 = Bottom
  // Second field indicates which row of points (from 0 to 3, aka size of divisions + 1)
  // Third Field ondicates which specific point (from 0 to 3, aka size of divisions + 1)
  float[][][][] points = generatePoints(size, divisions);
  int numTriangles = 2 * (int)Math.pow(divisions, 2) * 6; //Number of triangles on cube is equal to (2 triangles) * (divisions^2 square sections) * (6 faces) 
  
  //Initializes lists to the size of numTriangle
  cubeList = new Triangle[numTriangles];
  rotatedList = new Triangle[numTriangles];
  int cubeIndex = 0; //Holds the current point in cubeList
  
  //Loops through every point from every face to make a triangle, and adds it to cubeList
  for(int i = 0; i < 6; i++) {           //Which dace is currently being accessed
   for(int j = 0; j < divisions; j++){   //Which Row is currently being accessed
    for(int k = 0; k < divisions; k++){  //Which point to start from
      cubeList[cubeIndex] = new Triangle(points[i][j][k],points[i][j+1][k+1], points[i][j+1][k]);
      cubeIndex++;
      cubeList[cubeIndex] = new Triangle(points[i][j][k],points[i][j][k+1], points[i][j+1][k+1]);
      cubeIndex++;
    }
   }
  }
  
 return null;
}

float[][][][] generatePoints(int size, int divisions){
  //3d array to hold points, the current face being looked at is the first parameter:
  //    0 = Front
  //    1 = Back
  //    2 = Left
  //    3 = Right
  //    4 = Top
  //    5 = Bottom
  // Second field indicates which row of points (from 0 to 3, aka size ov divisions + 1)
  // Third Field ondicates which specific point (from 0 to 3, aka size ov divisions + 1)
  float[][][][] points = new float[6][divisions+1][divisions+1][];
  
  //Number to iterate by for each point coordinate in space, derived by the length of one side (2*size) divided by the number of divisions
  int numIncrease = (2*size)/divisions;
  
  //Holds the current axis point location, set to max value of size;
  int xbase = size;
  int ybase = size;
  int zbase = size;
  
  //Front Face
  //Loops for every point in column
  for(int i = 0; i < divisions + 1; i++){
    //Loops for every point in row
    for(int k = 0; k < divisions + 1; k++){
      //Sets current x and y and z coords
      points[0][i][k] = new float[3];
      points[0][i][k][X] = xbase;
      points[0][i][k][Y] = ybase;
      points[0][i][k][Z] = zbase;
      
      //Decreases x
      xbase-=numIncrease;
    }
    ybase -= numIncrease;
    xbase = size;
  }
  
  //Back Face
  //Sets x, y, and z coords to start parameters
  xbase = -size;
  ybase = size;
  zbase = -size;
  //Loops for every point in column
  for(int i = 0; i < divisions + 1; i++){
    //Loops for every point in row
    for(int k = 0; k < divisions + 1; k++){
      //Sets current x and y and z coords
      
      points[1][i][k] = new float[3];
      points[1][i][k][X] = xbase;
      points[1][i][k][Y] = ybase;
      points[1][i][k][Z] = zbase;
      
      //Decreases x
      xbase+=numIncrease;
    }
    
    //Decreases y and resets x
    ybase -= numIncrease;
    xbase = -size;
}
  
  //Left Face
  xbase = -size; //X set to -size for entire loop
  ybase = -size; //Y reset to max value
  zbase = size;
  
  //Loops for every point in column
  for(int i = 0; i < divisions + 1; i++){
    //Loops for every point in row
    for(int k = 0; k < divisions + 1; k++){
      //Sets current x and y and z coords
      points[2][i][k] = new float[3];
      points[2][i][k][X] = xbase;
      points[2][i][k][Y] = ybase;
      points[2][i][k][Z] = zbase;
      
      //Decreases x
      ybase+=numIncrease;
    }
    
    //Decreases y and resets x
    zbase -= numIncrease;
    ybase = -size;
}

  //Right Face
  xbase = size; //X set to size for entire loop
  ybase = size; //Y reset to max value
  zbase = size; //Reset Z to max value
  
  //Loops for every point in column
  for(int i = 0; i < divisions + 1; i++){
    //Loops for every point in row
    for(int k = 0; k < divisions + 1; k++){
      //Sets current x and y and z coords
      
      points[3][i][k] = new float[3];
      points[3][i][k][X] = xbase;
      points[3][i][k][Y] = ybase;
      points[3][i][k][Z] = zbase;
      
      //Decreases x
      ybase-=numIncrease;
    }
    
    //Decreases y and resets x
    zbase -= numIncrease;
    ybase = size;
  }
  
  //Top Face
  xbase = -size; //X reset to max value
  ybase = size; //Y set to size for entire loop
  zbase = size; //Reset Z to max value
  
  //Loops for every point in column
  for(int i = 0; i < divisions + 1; i++){
    //Loops for every point in row
    for(int k = 0; k < divisions + 1; k++){
      //Sets current x and y and z coords
      points[4][i][k] = new float[3];
      points[4][i][k][X] = xbase;
      points[4][i][k][Y] = ybase;
      points[4][i][k][Z] = zbase;
      
      //Decreases x
      xbase+=numIncrease;
    }
    
    //Decreases y and resets x
    zbase -= numIncrease;
    xbase = -size;
  }
  
  //Bottom Face
  xbase = size; //X reset to max value
  ybase = -size; //Y set to -size for entire loop
  zbase = size; //Reset Z to max value
  
  //Loops for every point in column
  for(int i = 0; i < divisions + 1; i++){
    //Loops for every point in row
    for(int k = 0; k < divisions + 1; k++){
      //Sets current x and y and z coords 
      points[5][i][k] = new float[3];
      points[5][i][k][X] = xbase;
      points[5][i][k][Y] = ybase;
      points[5][i][k][Z] = zbase;
      
      //Decreases x
      xbase-=numIncrease;
    }
    
    //Decreases y and resets x
    zbase -= numIncrease;
    xbase = size;
  }
  
  return points;
}


//Goes through all the points in a given array and prints them (After projecting them from 3D to 2D to display better)
void printPoints(float [][][][] points, int rowLimit){
  float[] v; //Stores projected vertex to print
  
  for(int i = 0; i < 6; i++) {
   for(int j = 0; j < rowLimit; j++) {
    for(int k = 0; k < rowLimit; k++){
      v = projectVertex(points[i][j][k]);    
      setPixel(v[X],v[Y]);
    }
   }
  }
}

/* 
Receives an array of triangles and draws them on the raster by 
calling draw2DTriangle()
*/
void drawTriangles(Triangle[] list) { 
  //Loops through each triangle
  for(int i = 0; i < list.length; i++) {
    draw2DTriangle(list[i]);
  }
}

/*
Use the projected vertices to draw the 2D triangle on the raster.
Several tasks need to be implemented:
 - cull degenerate or back-facing triangles (DONE)
 - calculate face or vertex colors as required by the current shading model
 - draw triangle edges using bresenhamLine() (DONE)
 - fill the interior using fillTriangle() (DONE)
*/
void draw2DTriangle(Triangle t) {
  //Calculates 2 edges using projected vertivies of triangle, and their cross product to determine if the triangle should be rendered
  float[] e1 = subtract(t.pv2, t.pv1);
  float[] e2 = subtract(t.pv3, t.pv2);
  float cross =  cross2D(e1, e2);
  
  //Normals for each vertex and the face, used in Phong shading
  float[] n1 = cross3D(subtract(t.v2, t.v1), subtract(t.v3, t.v2));
  float[] n2 = cross3D(subtract(t.v3, t.v2), subtract(t.v1, t.v3));
  float[] n3 = cross3D(subtract(t.v1, t.v3), subtract(t.v2, t.v1));
  float[] faceNormal;
  
  float[] light; //Holds colour return value when calling Phong shading
  float[] mid = new float[3]; //Holds midpoint of triangle (X, Y, Z coordinate)
  
  //In case any vertex of the triangle is culled or if a triangle is back facing, the triangle is ommitted from being drawn
  if(t.pv1 != null && t.pv2 != null && t.pv3 != null && cross > 1){
    //FILLING/SHADING MODEL SELECTION
    //Flat Shading: Sets colour to base colour and calls fillTriangle to fill it in that colour
    if(displayMode == DisplayMode.FLAT){
      setColor(FILL_COLOR[R], FILL_COLOR[G], FILL_COLOR[B]);
      fillTriangle(t);
    }
    
    //Barycentric: calls fill triangle, shading depends on barycentric coordinates figured out during processing
    else if(displayMode == DisplayMode.BARYCENTRIC){
      fillTriangle(t);
    }
    
    //Face Level Phong: Phong shades entire triangle from center point
    else if(displayMode == DisplayMode.PHONG_FACE){
      //Averages out verticies to get mid point
      mid[X] = (t.v1[X] + t.v2[X] + t.v3[X])/3;
      mid[Y] = (t.v1[Y] + t.v2[Y] + t.v3[Y])/3;
      mid[Z] = (t.v1[Z] + t.v2[Z] + t.v3[Z])/3;
      
      //Calculates normal vector for face by getting the cross product of vectors from midpoint to v1 and v2
      faceNormal = cross3D(subtract(t.v1, mid), subtract(t.v2, mid));
      
      //Get phong lighting vector and set colour to it, then colours entire plane in that volour value
      light = phong(mid, faceNormal, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
      setColor(light[R], light[B], light[G]);
      fillTriangle(t);
    }
    
    //Vertex Level Phong: Phong shades entire triangle based on average colour from all verticies
    else if(displayMode == DisplayMode.PHONG_VERTEX){
      //Gets phong values for each vertex
      float[] r1 = phong(t.v1, n1, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
      float[] r2 = phong(t.v2, n2, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
      float[] r3 = phong(t.v3, n3, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
      
      //Averages out colours and colours entire face
      setColor((r1[R] + r2[R] + r3[R])/3,(r1[G] + r2[G] + r3[G])/3, (r1[B] + r2[B] + r3[B])/3);
      fillTriangle(t);
    }
    
    //Phong Gouraud Shading: Uses barycentric coordinates as weights for the colour calculated at each vertex to calculate colour at each pixel.
    else if(displayMode == DisplayMode.PHONG_GOURAUD){
      fillTriangle(t);
    }
    
    //Phong Shading: Phong shading is called at for each pixel
    else if(displayMode == DisplayMode.PHONG_SHADING) {
      fillTriangle(t);
    }
    

    //DEBUG OPTIONS
    //Prints triangle map on top of shaded cube
    if(doOutline){
      //Sets line colour to red, and draws each line
      setColor(OUTLINE_COLOR[R], OUTLINE_COLOR[G], OUTLINE_COLOR[B]);
      bresenhamLine((int)t.pv1[X], (int)t.pv1[Y], (int)t.pv2[X], (int)t.pv2[Y]);
      bresenhamLine((int)t.pv2[X], (int)t.pv2[Y], (int)t.pv3[X], (int)t.pv3[Y]);
      bresenhamLine((int)t.pv3[X], (int)t.pv3[Y], (int)t.pv1[X], (int)t.pv1[Y]);
    }
    
    //Prints the face and vertex normals of the cube, yellow for vertecies and blue for faces
    if(doNormals) {
      drawNormals(t);
    }
  }
}


/*
Fill the 2D triangle on the raster, using a scanline algorithm.
Modify the raster using setColor() and setPixel() ONLY.
*/
void fillTriangle(Triangle t) { 
  //Gets min and max coordinates for the bounding box
  float xMin = getMin(t.pv1[X], t.pv2[X], t.pv3[X]);
  float xMax = getMax(t.pv1[X], t.pv2[X], t.pv3[X]);
  float yMin = getMin(t.pv1[Y], t.pv2[Y], t.pv3[Y]);
  float yMax = getMax(t.pv1[Y], t.pv2[Y], t.pv3[Y]);
  
  //Gets edges of current triangle
  float[] E1 = subtract(t.pv2, t.pv1);
  float[] E2 = subtract(t.pv3, t.pv2);
  float[] E3 = subtract(t.pv1, t.pv3);
  
  //Point p, a point within bounding box of triangle, used tto figure out if a point is in the triangle and needs to be colored
  float[] p2D = new float[2]; //point p in 2d space, used to find barycentric coordinates
  float[] p3D = new float[3]; //point p in 3d space, used for phong shading, found using barycentric coordinates
  
  //Vectors from point p to each triangle vertex
  float[] P1;
  float[] P2;
  float[] P3;
  
  //Cross products used to check if p is in triangle and for area calculations
  float totalArea = cross2D(E1, E2);
  float u;
  float v;
  float w;
  
  //Phong Shading values
  //Normal vectors at each vertex
  float[] n1 = cross3D(subtract(t.v2, t.v1), subtract(t.v3, t.v2));
  float[] n2 = cross3D(subtract(t.v3, t.v2), subtract(t.v1, t.v3));
  float[] n3 = cross3D(subtract(t.v1, t.v3), subtract(t.v2, t.v1));
  float[] pointNormal = new float[3]; //Interpolated normal vector accross entire plane using vertex normals and barycentric coordinates, used in phong shading
   
  //Phong colour values at each vertex
  float[] c1 = phong(t.v1, n1, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
  float[] c2 = phong(t.v2, n2, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
  float[] c3 = phong(t.v3, n3, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
  
  //Loops through each point p in within bounding box and checks if it is in the triangle
  for(int y = (int)yMin; y <= (int)yMax; y++){
    for(int x = (int) xMin; x <= (int) xMax; x++){
      //Set current point equal to current x, y
      p2D[X] = x;
      p2D[Y] = y;
      
      //Calculates edges from each vertex to current point p
      P1 = subtract(p2D, t.pv1);
      P2 = subtract(p2D, t.pv2);
      P3 = subtract(p2D, t.pv3);
      
      //Calculates area from 2D cross products and divides them by total traingle area to get barycentric coordinate weights for the point p
      u = cross2D(E1, P1)/totalArea;
      v = cross2D(E2, P2)/totalArea;
      w = cross2D(E3, P3)/totalArea;
      
      //If all barycentric weights are greater than 0, point p is within the triangle
      if(u > 0 && v > 0 && w > 0) {
        
       //Checks for barycentric shading and changes colour based on current point coordinates
       if(displayMode == DisplayMode.BARYCENTRIC){
         setColor(w, v, u);
         setPixel(x, y);
       }
       
       //Checks for phong gouraud shading and averages out colour values using barycentric coordinates and colors each pixel
       else if(displayMode == DisplayMode.PHONG_GOURAUD){
         setColor(v*c1[R] + w*c2[R] + u*c3[R], v*c1[G] + w*c2[G] + u*c3[G], v*c1[B] + w*c2[B] + u*c3[B]);
         setPixel(x, y);    
       }
       
       //Checks for full phong shading and calculates colour for each pixel individually
       else if(displayMode == DisplayMode.PHONG_SHADING) {
         //Interpolates normals across plane to get normal vector at current point p
         //Also interpolates point to get current point p, in 3D world coordinates
         for(int i = 0; i < 3; i++) {
           pointNormal[i] = v*n1[i] + w*n2[i] + u*n3[i];
           p3D[i] = v*t.v1[i] + w*t.v2[i] + u*t.v3[i];
         }
         
         //Calculates colour value at point and colours pixel accordingly
         c1 = phong(p3D, pointNormal, EYE, LIGHT, MATERIAL, FILL_COLOR, PHONG_SHININESS);
         setColor(c1[R], c1[G], c1[B]);
         setPixel(x, y);
       }
       
       //Every other filling model fills according to current colour set before method call
       else {
         setPixel(x, y);
       }
      }
      
      //Else, at least one barycentric weight <= 0, therefore current p is not in triangle
      //Therefore point is not coloured
    }
  }
}

void drawNormals(Triangle t) {  
  float[] midPoint = {(t.v1[0] + t.v2[0] + t.v3[0])/3, (t.v1[1] + t.v2[1] + t.v3[1])/3, (t.v1[2] + t.v2[2] + t.v3[2])/3}; //Calculates midpoint
  float[] end; //Holds end point in direction of current normal, used to draw the line
  
  //Gets normal vector of face and mid point of triangle 
  //Note: all 3 normal vectors should be same as the triangle is a flat 2D object, but this is just to make sure nothing has gone horribly wrong
  float[] n1 = cross3D(subtract(t.v2, t.v1), subtract(t.v3, t.v2));
  float[] n2 = cross3D(subtract(t.v3, t.v2), subtract(t.v1, t.v3));
  float[] n3 = cross3D(subtract(t.v1, t.v3), subtract(t.v2, t.v1));
  float[] faceNormal = cross3D(subtract(t.v1, midPoint), subtract(t.v2, midPoint));
  
  //Normalizes all vectors
  normalize(n1);
  normalize(n2);
  normalize(n3);
  normalize(faceNormal);
  
  //Holds normal at current point
  float[] pointNormal = {midPoint[X] +  20*faceNormal[X], midPoint[Y] + 20*faceNormal[Y], midPoint[Z] + 20*faceNormal[Z]};
  
  //Projects both points to 2D
  midPoint = projectVertex(midPoint);
  end = projectVertex(pointNormal);
  
  //Sets color to blue and draws line for surface normal
  setColor(0, 0, 1);
  bresenhamLine((int) midPoint[X], (int) midPoint[Y], (int) end[X], (int) end[Y]);
  
  //Sets color to yellow and draws vertex normals
  setColor(1,1,0);
  
  //Vertex normal 1
  //Combines normal vector 1 times 20 pixels with vector 1, to get an endpoint in the same direction as the normal, projects it to 2d, then prints it
  for(int i = 0; i < 3; i++){
    pointNormal[i] = t.v1[i] + 20*n1[i];
  }
  end = projectVertex(pointNormal);
  bresenhamLine((int) t.pv1[X], (int) t.pv1[Y], (int) end[X], (int) end[Y]);
  
  //Vertex normal 2
  //Combines normal vector 2 times 20 pixels with vector 1, to get an endpoint in the same direction as the normal, projects it to 2d, then prints it
  for(int i = 0; i < 3; i++){
    pointNormal[i] = t.v2[i] + 20*n2[i];
  }
  end = projectVertex(pointNormal);
  bresenhamLine((int) t.pv2[X], (int) t.pv2[Y], (int) end[X], (int) end[Y]);
  
  //Vertex normal 3
  //Combines normal vector 3 times 20 pixels with vector 1, to get an endpoint in the same direction as the normal, projects it to 2d, then prints it
  for(int i = 0; i < 3; i++){
    pointNormal[i] = t.v3[i] + 20*n3[i];
  }
  end = projectVertex(pointNormal);
  bresenhamLine((int) t.pv3[X], (int) t.pv3[Y], (int) end[X], (int) end[Y]);
}

/*
Given a point p, normal vector n, eye location, light location, and various
material properties, calculate the Phong lighting at that point (see course 
notes and the assignment text for more details).
Return a vector of length 3 containing the calculated RGB values.
*/
float[] phong(float[] p, float[] n, float[] eye, float[] light, 
  float[] material, float[] fillColor, float s)
{
  //Holds the final colour value to return (RGB value)
  float[] result = new float[3];
  
  //Light colour terms: Set initialy to the fill colour
  float[] ambient = {fillColor[R],fillColor[G], fillColor[B]};
  float[] diffused = {fillColor[R],fillColor[G], fillColor[B]};
  float[] specular = {fillColor[R],fillColor[G], fillColor[B]};
  
  //RGB Material colors: hold the given reflectiveness of the material for each of the light terms, hold a decimal value < 0
  float ma = material[M_AMBIENT]; //Material reflectiveness for ambient
  float md = material[M_DIFFUSE]; //Material reflectiveness for diffuese
  float ms = material[M_SPECULAR]; //Material reflectiveness for specular
  
  //Scalars: used in calculations
  float LN; //Cross product of light vector and nomral vector
  double RV; //Cross product of reflect vector and view vector
  
  //Vectors used in calculations, derivec from given point p, eye, and light values
  float[] viewVector = subtract(eye, p);
  float[] lightVector = subtract(light, p);
  float[] reflectVector = new float[3];     //Holds the reflection of the light vector, calculated later
  
  //Normalizes all vectors
  normalize(n);
  normalize(viewVector);
  normalize(lightVector);
  
  //Calculates LN , if negative result is culled to 0
  LN = dot(lightVector, n);
  if(LN < 0) {
   LN = 0;
  }
  
  //Calculates reflect vector using LN and normalizes it
  for(int i = 0; i < 3; i++) {
    reflectVector[i] = 2*LN*n[i];
  }
  reflectVector = subtract(reflectVector, lightVector);
  normalize(reflectVector);
  
  //Calculates scalar RV, if the dot product is nbegative, it is culled
  //Otherwise the dot product is scaled to the given specular brightness s
  RV = dot(reflectVector, viewVector);
  if(RV > 0) {
   RV = Math.pow(RV, s); 
  }
  
  //Culls RV if negative
  else {
    RV = 0;
  } 
  
  //Calculates diffused and specular vectors
  for(int i = 0; i < 3; i++){
    diffused[i] = diffused[i]*LN;
    specular[i] = (specular[i]*(float)RV);
  }
  
  //Loops through and multiplies each light vector by their material reflectiveness scalar
  //Then combines them into one result RGB color vector
  for(int i = 0; i < 3; i++){
   //Combines all light values into one vector
   result[i] = ma*ambient[i] + md*diffused[i] + ms*specular[i];
  }
  
  return result;
}

/*
Use Bresenham's line algorithm to draw a line on the raster between 
the two given points. Modify the raster using setColor() and setPixel() ONLY.
*/
void bresenhamLine(int fromX, int fromY, int toX, int toY) {
  int X = fromX;
  int Y = fromY;
  int deltaX = toX - fromX; //Holds the change in X
  int deltaY = toY - fromY; //Holds the change in Y
  int stepX = 0; //What to increase/decrease X by each loop, set to 0 in case of straight line in Y direction
  int stepY = 0; //What to increase/decrease Y by each loop, set to 0 in case of straight line in X direction
  float slope = 0; //Slope of the line, set to 0 in case of divide by 0 error
  double error; //Error Term used to calculate what pixel to shade
  
  //Setting Step Variable
  //Checks if deltaX and deltaY are positive or negative
  //  If negative: line decreases on that axis
  //  If positive: line increases on that axis
  if(deltaX < 0){
    stepX = -1;
    deltaX = -deltaX;
  }
  else if(deltaX > 0){
    stepX = 1; 
  }
  if(deltaY < 0){
    stepY = -1;
    deltaY = -deltaY;
  }
  else if(deltaY > 0){
    stepY = 1; 
  }
  
  //Checks which axis is the fast direction by comparing the deltas of both X and Y
  //If deltaX > deltaY, then X is the fast direction and we increment in the X direction
  if(deltaX > deltaY){
    if(deltaX != 0) {
      slope = (float)deltaY/deltaX; //Set error to slope of Y/X as X is the fast direction
    }
    error = slope;
    
   //Loop through entire line until current point X is equal to the endpoint X
   while(X != toX){
     setPixel(X, Y); //Sets Pixel at current point X, Y
     X += stepX; // Moves point X axis by one in either positive or negative direction depending on the line
     
     //Error Calculations:
     //If the error reaches greater than 0.5, the line intersects the next Y pixel, therefore Y is incremented and error is reset to -1 (bottom of the next pixel)
     if(error > 0.5) {
       Y += stepY;
       error -= 1;
     }
     
     //Increases error by slope as we have moved one point over on the line
     error += slope;
   }
  }
  
  //Else, then Y is the fast direction and we increment in the Y direction
  else {
    if(deltaY != 0){
      slope = (float)deltaX/deltaY; //Set error to s;ope of X/Y as Y is the fast direction
    }
    error = slope;
   
   //Loop through entire line until current point Y is equal to the endpoint Y
    while(Y != toY){
      setPixel(X, Y); //Sets Pixel at current point X, Y
      Y += stepY; // Moves point Y axis by one in either positive or negative direction depending on the line
     
     //Error Calculations:
     //If the error reaches greater than 0.5, the line intersects the next X pixel, therefore Y is incremented and error is reset to -1 (bottom of the next pixel)
     if(error > 0.5){
       X += stepX;
       error -= 1;
     }
     
     //Increases error by slope as we have moved one point over on the line
     error += slope;
   }
  }
}
