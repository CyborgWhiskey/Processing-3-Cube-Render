final char KEY_OUTLINE = 'o';
final char KEY_ROTATE = ' ';
final char KEY_NORMALS = 'n'; // optional but strongly recommended
final char KEY_NEXT_MODE = 'm';
final char KEY_PREV_MODE = 'p';

//Keeps track of current rendering mode
enum DisplayMode {
  NONE,  // no shading
  FLAT, // solid colour
  BARYCENTRIC, // visualize barycentric coords
  PHONG_FACE, // Phong lighting calculated at triangle centers
  PHONG_VERTEX, // Phong lighting calculated at each vertex and averaged
  PHONG_GOURAUD, // Phong lighting calculated at each vertex, Gouraud shaded
  PHONG_SHADING // pixel-level Phong shading  
}
DisplayMode displayMode = DisplayMode.NONE;

//Keeps track of optional settings of cube
boolean doOutline = true; 
boolean doRotate = false;
boolean doNormals = false;

void keyPressed()
{
  if (key == KEY_NEXT_MODE) {
    int nextMode = (displayMode.ordinal()+1) % DisplayMode.values().length;
    displayMode = DisplayMode.values()[nextMode];
  }

  else if (key == KEY_PREV_MODE) {
    int prevMode = displayMode.ordinal()==0 ? DisplayMode.values().length-1 : displayMode.ordinal()-1;
    displayMode = DisplayMode.values()[prevMode];
  }
  
  else if (key == KEY_OUTLINE) {
    doOutline = !doOutline;
  }

  else if (key == KEY_ROTATE) {
    doRotate = !doRotate;
  }

  else if (key == KEY_NORMALS) {
    doNormals = !doNormals;
  }
  
  //Prints current settings to terminal
  printSettings();
}

//Displays the current cube settings to the terminal
void printSettings()
{
  String msg = "";
  msg += "Display Mode: "+displayMode+"  ";
  if (doRotate) msg += "(rotate) ";
  if (doOutline) msg += "(outlines) ";
  if (doNormals) msg += "(normals) ";
  println(msg);
}
