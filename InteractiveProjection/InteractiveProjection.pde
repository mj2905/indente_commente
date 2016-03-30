private float size = 1.0;
private float angleX = 0.0; //degrees
private float angleY = 0.0; //degrees
private boolean keys[] = {false, false, false, false}; //UP, DOWN, RIGHT, LEFT
//We use an array of keys, to use multiple keys at the same time


private final float SIZE_MODIFICATION = 0.01;
private final float ANGLE_MODIFICATION = 5;

void settings() {
  size(1000, 1000, P2D);
}

void setup() {
  
}
void draw() {
  background(255,255,255);
  My3DPoint eye = new My3DPoint(0, 0, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0);
  My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);
  
  modifyAngles();
  
  float[][] transformRotationX = rotateXMatrix(radians(angleX));
  input3DBox = transformBox(input3DBox, transformRotationX);
  
  float[][] transformRotationY = rotateYMatrix(radians(angleY));
  input3DBox = transformBox(input3DBox, transformRotationY);
  
  float[][] transformScale = scaleMatrix(size,size,size);
  input3DBox = transformBox(input3DBox, transformScale);
  
  float[][] transformTranslationCenter = translationMatrix(width/2,height/2,0);
  input3DBox = transformBox(input3DBox, transformTranslationCenter);
  
  projectBox(eye, input3DBox).render();
  
}

void modifyAngles() {
  if(keys[0]) angleX += ANGLE_MODIFICATION;
  if(keys[1]) angleX -= ANGLE_MODIFICATION;
  if(keys[2]) angleY += ANGLE_MODIFICATION;
  if(keys[3]) angleY -= ANGLE_MODIFICATION;
}

void mouseDragged() {
 if(pmouseY - mouseY > 0) size += SIZE_MODIFICATION;
 else if(pmouseY - mouseY < 0) size -= SIZE_MODIFICATION;
}

void keyPressed() {
   if(keyCode == UP) keys[0] = true;
   if(keyCode == DOWN) keys[1] = true;
   if(keyCode == RIGHT) keys[2] = true;
   if(keyCode == LEFT) keys[3] = true;
}

void keyReleased() {
   if(keyCode == UP) keys[0] = false;
   if(keyCode == DOWN) keys[1] = false;
   if(keyCode == RIGHT) keys[2] = false;
   if(keyCode == LEFT) keys[3] = false;
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
  float denom = eye.z - p.z;
  return new My2DPoint(eye.z * (p.x - eye.x) / denom, eye.z * (p.y - eye.y) / denom);
}

My2DBox projectBox(My3DPoint eye, My3DBox box) {
    My2DPoint[] points = new My2DPoint[box.p.length];
    for (int i=0; i < points.length; ++i) {
      points[i] = projectPoint(eye, box.p[i]);
    }
    return new My2DBox(points);
  }

float[] homogeneous3DPoint(My3DPoint p) {
  float[] result = {p.x, p.y, p.z, 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return (new float[][] { {1, 0, 0, 0}, 
                          {0, cos(angle), sin(angle), 0}, 
                          {0, - sin(angle), cos(angle), 0}, 
                          {0, 0, 0, 1}});
}
float[][] rotateYMatrix(float angle) {
  return (new float[][] {{cos(angle), 0, -sin(angle), 0}, 
                          {0, 1, 0, 0}, 
                          {sin(angle), 0, cos(angle), 0}, 
                          {0, 0, 0, 1}});
}
float[][] rotateZMatrix(float angle) {
  return (new float[][] {{cos(angle), sin(angle), 0, 0}, 
                         {-sin(angle), cos(angle), 0, 0},
                         {0, 0, 1, 0}, 
                         {0, 0, 0, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {
  return (new float[][] {{x, 0, 0, 0}, 
                         {0, y, 0, 0}, 
                         {0, 0, z, 0}, 
                         {0, 0, 0, 1}});
}
float[][] translationMatrix(float x, float y, float z) {
  return (new float[][] {{1, 0, 0, x}, 
                          {0, 1, 0, y}, 
                          {0, 0, 1, z}, 
                          {0, 0, 0, 1}});
}

float[] matrixProduct(float[][] a, float[] b) {
  float[] c = new float[a.length];
  for (int i = 0; i < a.length; ++i) {
    c[i] = 0;
    for (int j=0; j < a[0].length; ++j) {
      c[i] += a[i][j] * b[j];
    }
  }
  return c;
}


My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
    My3DPoint[] p = new My3DPoint[box.p.length];
  for(int i=0; i < box.p.length; ++i) {
      //We multiply the point with the transformation matrix, and created an euclidian point with the result
      p[i] = euclidian3DPoint(matrixProduct(transformMatrix,homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(p);
}

My3DPoint euclidian3DPoint(float[] a) {
 return new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
}

/*
 (x - ex) ~= xp
 (y - ey) ~= yp
 (z - ez) ~= -ez
 (-z/ez + 1) ~= 1
 */