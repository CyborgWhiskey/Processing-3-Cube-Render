//Contains various math operations for simplicity

// create and return the vector v-w
float[] subtract(float[] v, float w[])
{
  float[] ans = new float[v.length];
  for(int i = 0; i < v.length; i++){
    ans[i] = v[i] - w[i];
  }
  return ans;
}

// the 2D cross product, as discussed in Unit 1
// v and w are 2D vectors, result is a scalar
float cross2D(float[] v, float[] w)
{ 
  return (v[0]*w[1])-(v[1]*w[0]);
}

// the 3D cross product
// v and w are 3D vectors, result is a 3D vector
float[] cross3D(float[] v, float[] w)
{
  float[] ans = new float[3]; 
  ans[0] = (v[1]*w[2])-(v[2]*w[1]);
  ans[1] = (v[2]*w[0])-(v[0]*w[2]);
  ans[2] = (v[0]*w[1])-(v[1]*w[0]);
 
  return ans;
}

// dot product
// v and w are vectors of the same length, result is a scalar
float dot(float[] v, float[] w)
{
  float ans = 0;
  
  for(int i = 0; i < v.length; i++){
    ans += v[i]*w[i];
  }
  return ans;
}

// length of vector
float length(float[] v) {
  float sum = 0;
  
  for(int i = 0; i < v.length; i++){
    sum+=Math.pow(v[i], 2);
  }
  
  return sqrt(sum);
}

//Returns the smallest of 3 float values
float getMin(float x, float y, float z){
 float min = x;
 if(y < min){min = y;}
 if(z < min){min = z;}
 
 return min;
}

//Returns the largest of 3 float values
float getMax(float x, float y, float z){
 float max = x;
 if(y > max){max = y;}
 if(z > max){max = z;}
 
 return max;
}

// normalize vector to length 1 in place
void normalize(float[] v)
{
  float l = length(v);
  
  //Loops through each vector component and divides it by the length of v
  for(int i = 0; i < v.length; i++){
    v[i] /= l;
  }
}
