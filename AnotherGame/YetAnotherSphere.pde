public class YetAnotherSphere{
  // Propriétés primaires de la sphere: elle a la forme d'une sphere, une texture associée, et est rattachée à une plaque
  private float radius;
  private PShape s;
  private PImage img;
  private AnotherPlate plate;
  
  // Ici les propriétés "physiques" de la sphere
  private PVector position;
  private PVector gravityForce;
  private float bouncing = 0.95;
  private PVector speed;
  
  public YetAnotherSphere(PShape s, PImage img, AnotherPlate plate, float radius){
    this.s = s;
    this.img = img;
    this.plate = plate;
    gravityForce = new PVector(sin(plate.getRotZ())*gravityConstant, 
                               sin(plate.getRotX())*gravityConstant);
    speed = new PVector(0, 0);
    this.position = new PVector(0, 0);
    this.radius = radius;
   }
   
  void update() {
    if (max(abs(radians(plate.getRotZ())), abs(radians(plate.getRotX())))>plate.getMu()) {
      gravityForce.set(sin(radians(plate.getRotZ()))*gravityConstant, 
                      -sin(radians(plate.getRotX()))*gravityConstant);
    }
    else {
      gravityForce.set(0,0);
    }
    
    speed.add(gravityForce).mult(0.95);
    position.add(speed);
    collisionX();
    collisionZ();
    
  }
  
  void collisionX() {
    if (position.x>plate.getSizeX()/2){
      position.x=plate.getSizeX()/2;
      speed.x*=(-bouncing);
    }
    else if (position.x<-plate.getSizeX()/2){
      position.x=-plate.getSizeX()/2;
      speed.x*=(-bouncing);
    }
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
    s.setTexture(img);
    translate(position.x, -radius-0.5*plate.getSizeY(), position.y); 
    shape(s);
    popMatrix();

  }
  
}