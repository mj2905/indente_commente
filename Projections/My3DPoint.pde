class My3DPoint {
 float x, y, z;
 My3DPoint(float x, float y, float z) {
  this.x = x;
  this.y = y;
  this.z = z;
 }
 
 My3DPoint(float[] p) {
   this(p[0],p[1],p[2]); 
 }

  
}