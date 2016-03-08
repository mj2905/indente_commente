/**
*  Plate class, representing the plate in the view.
*  This plate can be rotated along the X and Z axis, within the range [-60; 60] degrees (in the class, in radians)
*  There are no rotations along the Y axis.
*/

public class Plate {
  
  //step of speed and limits for the rotation speed of the plate
  private final float STEP_OF_SPEED = 0.1, MIN_SPEED = 0.2, MAX_SPEED = 5;
  
  private final float sizeX;
  private final float sizeY;
  private final float sizeZ;
  private float rotationX;
  private float rotationY;
  private float rotationZ;
  private float speed;
  
  public float getSizeX() {
     return sizeX; 
  }
  
  public float getSizeY() {
     return sizeY; 
  }
  
  public float getSizeZ() {
     return sizeZ; 
  }
  
  public float getRotX() {
     return toDegrees(rotationX); 
  }
  
  public float getRotY() {
     return toDegrees(rotationY); 
  }
  
  public float getRotZ() {
     return toDegrees(rotationZ); 
  }
  
  public float getSpeed() {
   return speed; 
  }
  
  public void setRotX(float rotX) {
      if(rotX > 60) {
        rotationX = toRadians(60);
      }
      else if(rotX < -60) {
       rotationX = toRadians(-60); 
      }
      else {
        rotationX = toRadians(rotX);
      }
  }
  
  public void setRotZ(float rotZ) {
      if(rotZ > 60) {
        rotationZ = toRadians(60);
      }
      else if(rotZ < -60) {
       rotationZ = toRadians(-60); 
      }
      else {
        rotationZ = toRadians(rotZ);
      }
  }
  
  public void setSpeed(float speed) {
     if(speed > MAX_SPEED) {
       this.speed = MAX_SPEED;
     }
     else if(speed < MIN_SPEED) {
       this.speed = MIN_SPEED;
     }
     else {
       this.speed = speed; 
     }
  }
  
  
  public Plate(float sizeX, float sizeY, float sizeZ) {
    this(sizeX, sizeY, sizeZ, 0,0);
  }
  
  public Plate(float sizeX, float sizeY, float sizeZ, float rotX, float rotZ) {
   this.sizeX = sizeX;
   this.sizeY = sizeY;
   this.sizeZ = sizeZ;
   setRotX(rotX);
   this.rotationY = 0;
   setRotZ(rotZ);
   this.speed = 1;
  }
  
  private float toRadians(float angleInDegree) {
   return angleInDegree * PI / 180; 
  }
  
  private float toDegrees(float angleInRadians) {
   return angleInRadians * 180 / PI; 
  }
  
  public void render() {
      fill(133,123,227);
      rotateX(rotationX);
      rotateY(rotationY);
      rotateZ(rotationZ);
      box(sizeX,sizeY,sizeZ);
  }
  
}