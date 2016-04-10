public class Sphere {
  private final float radius;
  private PVector position;
  private PVector speed;
  private Plate plate;
  private PVector gravityForce;
  //private PVector friction;
  private float bouncing = 0.95;
  //given that friction vector and gravity vector are proportional, we only use an attenuation
  private float attenuation = 0.95;
  
  private PVector oldPosition; //For data visualization
  
  
  Sphere(Plate plate, float r) {
    this.plate = plate;
    this.position = new PVector(0, 0);
    this.radius = r;
    
    this.oldPosition = new PVector(0,0);
    
    //To define this vector once
    gravityForce = new PVector(sin(plate.getRotZ())*gravityConstant, 
                               sin(plate.getRotX())*gravityConstant);
    speed = new PVector(0, 0);
  }
  
  public PVector getPosition() { return position.copy(); }
  public PVector getOldPosition() { return oldPosition.copy(); }
  public float getRadius() { return radius; }
  
  void update() {
    oldPosition = position.copy();
    gravity();
    boxCollisions();
    checkCylindersCollision();
  }
  
  /**
  Checks for every cylinder if there is a collision or not
  */
  
  void checkCylindersCollision(){
    
      List<Cylinder> cylinders = plate.cylinders;
      for(Cylinder c: cylinders){
         cylinderCollision(c);
      }
    
  }
  
  void cylinderCollision(Cylinder c){
      float dist = position.dist(c.position); // This vector is the distance center to center between the sphere and the cylinder.
      float minDist = radius + c.radius;
      if(abs(dist) <= abs(minDist)){  // If the distance between the two centers is smaller or equal to the sum of the radius, there is a collision
        Game.addToScore(speed.mag());  
      
        PVector n = new PVector(position.x - c.position.x, position.y - c.position.y);
        position = correctPosition(c, n, minDist);
        speed = bouncingSpeed(speed, n);
        
      }
  }
  
  /**
  This method corrects the position of the sphere relative to a cylinder. It is the one that manages collisions with any given cylinder!
  */
  
  PVector correctPosition(Cylinder c, PVector normal, float minDist){
    PVector xAxis = new PVector(1,0);
    PVector yAxis = new PVector(0,1);

    float p =  c.position.x + minDist*cos(PVector.angleBetween(xAxis, normal));
    float d =  c.position.y + minDist*cos(PVector.angleBetween(yAxis, normal));
    return new PVector(p,d);

  }
  
  
  /**
  This method simply corrects the bouncing speed using the formula from the statement.
  */
  PVector bouncingSpeed(PVector disSpeed, PVector norma){
    PVector n = norma.normalize();
    float number1 = n.dot(disSpeed)*2;
    PVector vPrime = n.mult(number1);
    return disSpeed.sub(vPrime).mult(bouncing);
  }
  
  /**
  Gravity is the method that simulates gravity. Granted that we have a sufficient angle (ie: at which the gravity exceeds friction) the ball will start moving.
  */
  void gravity(){
    float rotZRadians = radians(plate.getRotZ()), rotXRadians = radians(plate.getRotX());
    //If we have an angle around x or z that is more than the mu angle
    if (max(abs(rotZRadians), abs(rotXRadians))>plate.getMu())
      {
        gravityForce.set(sin(rotZRadians)*gravityConstant, 
                        -sin(rotXRadians)*gravityConstant);
      }
    else
    {
      gravityForce.set(0,0);
    }
    speed.add(gravityForce).mult(attenuation);
    position.add(speed);
  }
  
  
  void boxCollisions() {
    boolean collisionX = true, collisionZ = true;
    PVector oldSpeed = speed.copy();
    
    if (position.x>plate.getSizeX()/2)
      {
       position.x=plate.getSizeX()/2;
       speed.x*=(-bouncing);
     }
    else if (position.x<-plate.getSizeX()/2) 
      {
       position.x=-plate.getSizeX()/2;
       speed.x*=(-bouncing);
     }
     else {
       collisionX = false; 
     }
    
    if (position.y>plate.getSizeZ()/2)
      {
        position.y=plate.getSizeZ()/2;
       speed.y*=(-bouncing);
     }
    else if (position.y<-plate.getSizeZ()/2) 
      {
        position.y=-plate.getSizeZ()/2;
       speed.y*=(-bouncing);
     }
     else {
        collisionZ = false;
     }
     
     if(collisionX || collisionZ) {
       Game.addToScore(-oldSpeed.mag());
     }
  }
      
  
  void render(PGraphics layer) {
    layer.pushMatrix();
      layer.fill(00,66,255);
      //We print it on the plate
      layer.translate(position.x, -radius-0.5*plate.getSizeY(), position.y);
      layer.sphere(radius);
    layer.popMatrix();
  }
}
  