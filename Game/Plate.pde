/**
*  Plate class, representing the plate in the view.
*  This plate can be rotated along the X and Z axis, within the range [-60; 60] degrees (in the class, in radians)
*  There are no rotations along the Y axis.
*/

import java.util.List;


public class Plate {
  
  //step of speed and limits for the rotation speed of the plate
  private final float STEP_OF_SPEED = 0.1, MIN_SPEED = 0.2, MAX_SPEED = 5;
  private final float MAX_ANGLE = 60, MIN_ANGLE = -60;
  private final float SPHERE_RADIUS = 30;
  private final float MU = 0.1; //corresponds to the minimum angle necessary to apply force
  private final float sizeX;
  private final float sizeY;
  private final float sizeZ;
  private float rotationX;
  private float rotationY;
  private float rotationZ;
  private float speed;
  private final Sphere sphere;
  private final List<Cylinder> cylinders;
  
  private float modeRotXFreeze = 0, modeRotZFreeze = 0;
  private boolean normalMode;
  
  // a few fonctions to access attributes:
  public float getSizeX() { return sizeX; }
  public float getSizeY() { return sizeY; }
  public float getSizeZ() { return sizeZ; }
  public float getRotX() { return degrees(rotationX); }
  public float getRotY() { return degrees(rotationY); }
  public float getRotZ() { return degrees(rotationZ); }
  public float getSpeed() { return speed; }
  public float getMu() { return MU; }
  
  //constructors
  public Plate(float sizeX, float sizeY, float sizeZ) {
    this(sizeX, sizeY, sizeZ, 0, 0);
  }
  
  public Plate(float sizeX, float sizeY, float sizeZ, float rotX, float rotZ) {
   this.sizeX = sizeX;
   this.sizeY = sizeY;
   this.sizeZ = sizeZ;
   setRotX(rotX);
   this.rotationY = 0;
   setRotZ(rotZ);
   this.speed = 1;
   normalMode = true;
   cylinders = new ArrayList<Cylinder>();
   sphere = new Sphere(this, SPHERE_RADIUS);
  }
  
  public void setRotX(float rotX) {
      if(rotX > MAX_ANGLE) {
        rotationX = radians(MAX_ANGLE);
      }
      else if(rotX < MIN_ANGLE) {
       rotationX = radians(MIN_ANGLE); 
      }
      else {
        rotationX = radians(rotX);
      }
  }
  
  public void setRotZ(float rotZ) {
      if(rotZ > MAX_ANGLE) {
        rotationZ = radians(MAX_ANGLE);
      }
      else if(rotZ < MIN_ANGLE) {
       rotationZ = radians(MIN_ANGLE); 
      }
      else {
        rotationZ = radians(rotZ);
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
  
  
  //core of the class
  
  public void upMode() {
    if (normalMode) {
      ortho();
      modeRotXFreeze = rotationX;
      modeRotZFreeze = rotationZ;
      rotationX = -radians(90);
      rotationZ = radians(0);
      normalMode = false;
    }
  }
  
  public void normalMode() {
    if (!normalMode) {
      perspective();
      rotationX = modeRotXFreeze;
      rotationZ = modeRotZFreeze;
      normalMode = true;
    }
  }
  
  public void addCylinder() {
    if(!normalMode) {
      //cylinders.add(new Cylinder(this, new PVector((mouseX-width/2)*(this.sizeX/width), (mouseY-height/2)*(this.sizeZ/height))));
      if(mouseX > (width - sizeX)/2 && mouseX < (width + sizeX)/2 && mouseY > (height - sizeZ)/2 && mouseY < (height + sizeZ/2)) {
              cylinders.add(new Cylinder(this, new PVector((mouseX-width/2), (mouseY-height/2))));
      }
    }
  }
  
  public void render() {
      pushMatrix();
      fill(133,123,227);
      rotateX(rotationX);
      rotateY(rotationY);
      rotateZ(rotationZ);
      box(sizeX,sizeY,sizeZ);
      if (normalMode) {
        sphere.update();
      }
      sphere.render();
      for(int i=0; i < cylinders.size(); ++i) {
         cylinders.get(i).render(); 
      }
      popMatrix();
  }
  
  
  
}