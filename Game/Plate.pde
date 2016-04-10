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
  
  //Modes to keep the normal state while in Shift mode
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
  
  //upMode = mode in which we are in the top view, with an ortho camera (Shift mode)
  public void upMode(PGraphics layer) {
    if (normalMode) {
      layer.ortho();
      modeRotXFreeze = rotationX;
      modeRotZFreeze = rotationZ;
      rotationX = -radians(90);
      rotationZ = radians(0);
      normalMode = false;
    }
  }
  
  //upMode = mode in which we are in normal view with a perspective camera
  public void normalMode(PGraphics layer) {
    if (!normalMode) {
      layer.perspective();
      rotationX = modeRotXFreeze;
      rotationZ = modeRotZFreeze;
      normalMode = true;
    }
  }
  
  //function to add a cylinder in the plate (not touching the ball and not touching another cylinder)
  public void addCylinder(PGraphics layer) {
    if(!normalMode) {
      
      if(mouseX > (layer.width - sizeX)/2 && mouseX < (layer.width + sizeX)/2 && mouseY > (layer.height - sizeZ)/2 && mouseY < (layer.height + sizeZ)/2) {
              println("Hello");
              //If after we want to have cylinders with bigger radius to improve the game, we do this here.
              Cylinder cylinder = new Cylinder(this, new PVector((mouseX-layer.width/2), (mouseY-layer.height/2)));
              boolean isMouseInBall = (new PVector(mouseX - layer.width/2, mouseY - layer.height/2)).dist(sphere.getPosition()) < sphere.getRadius() + cylinder.radius;
              boolean isMouseInAnotherCylinder = false;
              for(Cylinder c : cylinders) {
                  isMouseInAnotherCylinder |= c.position.dist(cylinder.position) < c.radius + cylinder.radius;
              }
              
              if(!isMouseInBall && !isMouseInAnotherCylinder) {
                  cylinders.add(cylinder);
              }
      }
    }
  }
  
  public void render(PGraphics layer) {
      layer.pushMatrix();
      layer.fill(133,123,227);
      
      if (normalMode) {
        layer.rotateX(-PI/6); //To see beter the plate
        //If we are in normal mode, we update the ball
        sphere.update();
      }
      
      layer.rotateX(rotationX);
      layer.rotateY(rotationY);
      layer.rotateZ(rotationZ);
      layer.box(sizeX,sizeY,sizeZ);
      sphere.render(layer);
      for(Cylinder c: cylinders) {
         c.render(layer); 
      }
      layer.popMatrix();
  }
  
  
  
}