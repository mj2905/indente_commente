public class YetAnotherSphere{
  // Propriétés primaires de la sphere: elle a la forme d'une sphere, une texture associée, et est rattachée à une plaque
  private float radius;
  private PShape s;
  private PImage img;
  private AnotherPlate plate;
  private float attenuation = 0.95;
  
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
    gravity();
    boxCollision();
    checkCylindersCollision();
  }
  
  /**
  This method calls the two possible axis of collision of the sphere with the borders of the box, collisionX and collisionZ.
  */
  void boxCollision(){
    collisionX();
    collisionZ();
  }
  
  /**
  Checks for every cylinder if there is a collision or not!
  */
  
  void checkCylindersCollision(){
      List<AnotherCylinder> cylinders = plate.cylinders;
      for(AnotherCylinder c: cylinders){
         cylinderCollision(c);
      }
    
  }
  
  void cylinderCollision(AnotherCylinder c){
      float dist = position.dist(c.position); // This vector is the distance center to center between the sphere and the cylinder.
      float minDist = radius + c.radius;
      if(abs(dist) <= abs(minDist)){  // If the distance between the two centers is smaller or equal to the sum of the radius, there is a collision
        PVector n = new PVector(position.x - c.position.x, position.y - c.position.y);
        position = correctPosition(c, n, minDist);
        speed = bouncingSpeed(speed, n);
        
      }
  }
  
  /**
  This method corrects the position of the sphere relative to a cylinder. It is the one that manages collisions with any given cylinder!
  */
  
  PVector correctPosition(AnotherCylinder c, PVector normal, float minDist){
    PVector xAxis = new PVector(1,0);
    PVector yAxis = new PVector(0,1);

    float p =  c.position.x + minDist*cos(PVector.angleBetween(xAxis, normal));
    float d =  c.position.y + minDist*cos(PVector.angleBetween(yAxis, normal));
    return new PVector(p,d);

  }
  
  
  /**
  This method simply corrects the bouncing angle.
  */
  PVector bouncingSpeed(PVector disSpeed, PVector norma){
    PVector n = norma.normalize();
    float number1 = n.dot(disSpeed)*2;
    PVector vPrime = n.mult(number1);
    return disSpeed.sub(vPrime);
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
  
  
  void collisionX() {
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
  }
  
  void collisionZ() {
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
  }
      
   
   void render() {
    pushMatrix();
    s.setTexture(img);
    translate(position.x, -radius-0.5*plate.getSizeY(), position.y); 
    shape(s);
    popMatrix();

  }
  
}