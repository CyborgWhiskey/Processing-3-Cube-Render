import java.util.Arrays;

// GLOBAL CONSTANTS

// when you store (x,y) or (x,y,z) coordinates in an array,
// USE THESE NAMED CONSTANTS to access the entries
final int X = 0;    
final int Y = 1; 
final int Z = 2;

// when you store (r,g,b) values in an array,
//USE THESE NAMED CONSTANTS to access the entries
final int R = 0; 
final int G = 1; 
final int B = 2;

// for the cube and its tessellation
final int CUBE_SIZE = 150; //In pixels
final int CUBE_DIVISIONS = 5; //Number of triangles per side

// colors for drawing cube
final float[] OUTLINE_COLOR = {1.0f, 0.3f, .1f};  // RGB
final float[] FILL_COLOR    = {1.0f, 1.0f, 1.0f}; // RGB

// for projection and lighting
final float[] EYE = {0, 0, 600}; // location

// reasonable defaults for Phong lighting
final float[] LIGHT = {300, 300, 350}; // location
final float[] MATERIAL = {.35, .45, 0.3}; // ambient, diffuse, specular
final int M_AMBIENT = 0; // indices for material properties
final int M_DIFFUSE = 1; 
final int M_SPECULAR = 2;  
final float PHONG_SHININESS = 50; // exponent

// to change the current color
color _stateColor;
void setColor(float red, float green, float blue) {
  _stateColor = color(red, green, blue);
}

void setColor(color c) {
  _stateColor = c;
}

// draw a pixel at the given location
void setPixel(float x, float y) {
  int index = indexFromXYCoord(x, y);
  if (0 <= index && index < buffer.pixels.length) {
    buffer.pixels[index] = _stateColor;
  } else {
    println("ERROR:  this pixel is not within the raster.");
  }
}

// helper functions for pixel calculations
int indexFromXYCoord(float x, float y) {
  int col = colNumFromXCoord(x);
  int row = rowNumFromYCoord(y);
  return indexFromColRow(col, row);
}

int indexFromColRow(int col, int row) {
  return row*width+col;
}

int colNumFromXCoord(float x) {
  return (int)round(x+width/2);
}

int rowNumFromYCoord(float y) {
  return (int)round(height/2-y);
}


//Perspective projection. Parameter v is a 3D vector, return value is a 2D vector.
//Returns null if v is behind the position of the eye -- watch out for that result
//when you use this function in your code!
final float PERSPECTIVE = 0.002; // don't  change this value 
float[] projectVertex(float[] v) 
{
  float adjZ = v[Z]-EYE[Z];  // negative z direction points into the screen
  if (adjZ > 0) return null; // clipping plane at z coord of eye
  adjZ *=- 1; // use |z| for division 
  float px = v[X] / (adjZ*PERSPECTIVE);  // vanishing point calculation
  float py = v[Y] / (adjZ*PERSPECTIVE);
  return new float[]{px, py};
}

/*
Parameter v is a 3D vector. This function rotates v in place by theta in the Y,
Z, and X directions in succession.
This math will also be covered later in the course.
*/
void rotateVertex(float[] v, float theta)
{
  float rx, ry, rz;
  
  // y axis
  rx = v[X]*cos(theta) - v[Z]*sin(theta);
  rz = v[X]*sin(theta) + v[Z]*cos(theta);
  v[X] = rx; 
  v[Z] = rz;

  // z axis
  rx = v[X]*cos(theta) - v[Y]*sin(theta);
  ry = v[X]*sin(theta) + v[Y]*cos(theta);
  v[X] = rx; 
  v[Y] = ry;

  // x axis
  ry = v[Y]*cos(theta) - v[Z]*sin(theta);
  rz = v[Y]*sin(theta) + v[Z]*cos(theta);
  v[Y] = ry; 
  v[Z] = rz;
}


//Each triangle in the original list is copied into the rotated list,
//then rotated by the angle theta.
void rotateTriangles(Triangle[] original, Triangle[] rotated, float theta)
{
  if (original == null || rotated == null) return;
  for (int i = 0; i < original.length; i++)
  {
    if (rotated[i] == null) {
      rotated[i] = new Triangle(original[i].v1, original[i].v2, original[i].v3);
    }
    else
    {
      rotated[i].setVertices(original[i].v1, original[i].v2, original[i].v3);
    }
    rotated[i].rotate(theta);
  }
}

/*
Convert (x,y) coordinates so that the origin is at the top left
of the canvas, and add a shift that depends on the direction of
the line
*/
void correctedLine(int x0, int y0, int x1, int y1) {
  final int LINE_SHIFT = 5;
  
  // shift left/right or up/down
  int xDir = 0;
  int yDir = 0;
  if (x1-x0 > 0) yDir = -1;
  else if (x1-x0 < 0) yDir = 1;
  if (y1-y0 > 0) xDir = -1;
  else if (y1-y0 < 0) xDir = 1;
  
  buffer.line(width/2+x0+xDir*LINE_SHIFT, height/2-y0+yDir*LINE_SHIFT, 
    width/2+x1+xDir*LINE_SHIFT, height/2-y1+yDir*LINE_SHIFT);  
}
