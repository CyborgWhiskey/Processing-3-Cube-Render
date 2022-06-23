
# 3D Cube Render

This project uses processing 3 to display a 3D rotating cube with various lighting and shading modes. The cube is rendered in real time using normal shading and full phong lighting techniques. Note that this project uses pretty much my own implementation of every function instead of using the built in processing functions. Drawing a cube, bresenham line algorithim, and lighting modes are all coded by me.


## Authors

- [@AlexanderLannon](https://www.github.com/https://github.com/CyborgWhiskey)


## Running the program
Once the program is running in processing, there are 5 keybindings to use

- 'o' will turn on/off the triangle outline
- ' ' will turn on/off rotation
- 'n' will turn on/off the vertex and face normals of each triangle
- 'm' moves to the next rendering mode
- 'p' moves to the previous mode

There are 7 modes to choose from:
- NONE: There is no colour to the cube, so only the outline is shown (if enabled)
- FLAT: The cube is given a single flat shade
- BARYCENTRIC: The barycentric coordanates of each triangle are used to shade each triangle in the cube
- PHONG FACE: Each triangle is shaded by calculating the phong lighting value at the face normal and using that colour to shade the entire triangle
- PHONG VERTEX: Each triangle is shaded by calculating the phong lighting value at each vertex and using their average colour to shade the entire triangle
- PHONG GOURAUD: Each triangle is shaded by calculating the phong lighting value at each vertex and using barycentric coordinates to ease the shading accross the triangle
- PHONG SHADING: Phong lighting is calculated at each pixel of the cube