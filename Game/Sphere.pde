public class Sphere {
  private final float radius;
  private PVector position;
  private PVector speed;
  private Plate plate;
  private PVector gravityForce;
  //private PVector friction;
  private float bouncing = 0.95;
  
  Sphere(Plate plate, float r) {
    this.plate = plate;
    this.position = new PVector(0, 0);
    this.radius = r;
    gravityForce = new PVector(sin(plate.getRotZ())*gravityConstant, 
                               sin(plate.getRotX())*gravityConstant);
    speed = new PVector(0, 0);
  }
  
  
  
  void update() {
    if (max(abs(radians(plate.getRotZ())), abs(radians(plate.getRotX())))>plate.getMu())
      {gravityForce.set(sin(radians(plate.getRotZ()))*gravityConstant, 
                      -sin(radians(plate.getRotX()))*gravityConstant);}
    else
      {gravityForce.set(0,0);}
    speed.add(gravityForce).mult(0.95);
    position.add(speed);
    collisionX();
    collisionZ();
    
  }
  
  void collisionX() {
    if (position.x>plate.getSizeX()/2)
      {position.x=plate.getSizeX()/2;
       speed.x*=(-bouncing);}
    else if (position.x<-plate.getSizeX()/2) 
      {position.x=-plate.getSizeX()/2;
       speed.x*=(-bouncing);}
  }
  
  void collisionZ() {
    if (position.y>plate.getSizeZ()/2)
      {position.y=plate.getSizeZ()/2;
       speed.y*=(-bouncing);}
    else if (position.y<-plate.getSizeZ()/2) 
      {position.y=-plate.getSizeZ()/2;
       speed.y*=(-bouncing);}
  }
      
  
  void render() {
    pushMatrix();
    fill(00,66,255);
    translate(position.x, -radius-0.5*plate.getSizeY(), position.y);
    sphere(radius);
    popMatrix();
  }
}
  