public class Cylinder {
  private final static float cylinderBaseSize = 50;
  private final static float cylinderBaseHeight = 50;
  private final static int cylinderBaseResolution = 40;
  private Plate plate;
  private final float radius;
  private final PVector position;
  private PShape shape;
  private int cylinderResolution;
  private float cylinderHeight;
  
  Cylinder(Plate plate, PVector position) {
    this(plate, position, cylinderBaseSize, cylinderBaseHeight, cylinderBaseResolution);
  }
  
  Cylinder(Plate plate, PVector position, float r, float cylinderHeight, int cylinderResolution) {
    
    this.plate = plate;
    this.radius = r;
    this.cylinderResolution = cylinderResolution;
    this.cylinderHeight = cylinderHeight;
    this.position = position;
    
    PShape group = createShape(GROUP);
    group.addChild(openCylinder());
    group.addChild(surface());
    
    this.shape = group;
  }
  
  private PShape openCylinder() {
    float angle = TWO_PI / cylinderResolution;
    float pAngle;

    PShape openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    openCylinder.fill(30,105,255);
    openCylinder.noStroke();
    
    for(int i = 0; i < cylinderResolution+1; ++i) {
      pAngle = angle*i;
      openCylinder.vertex(sin(pAngle) * radius,              0, cos(pAngle) * radius);
      openCylinder.vertex(sin(pAngle) * radius, cylinderHeight, cos(pAngle) * radius);
    }
    
    openCylinder.endShape();
    
    return openCylinder;
  }
  
  private PShape surface() {
    
    float angle = TWO_PI / cylinderResolution;
    float p1Angle;
    float p2Angle;
    
    PShape surface = createShape();
    surface.beginShape(TRIANGLES);
    surface.fill(60,148,255);
    surface.noStroke();
    
    for(int i = 0; i < cylinderResolution+1; ++i) {
      
       p1Angle = angle*i;
       p2Angle = angle*(i+1);
       
       //Each time we create a point in (sin(angle), height, cos(angle))
       
       surface.vertex(sin(p1Angle) * radius,              0, cos(p1Angle) * radius);
       surface.vertex(sin(p2Angle) * radius,              0, cos(p2Angle) * radius);
       surface.vertex(                    0,              0,                     0);
       
       surface.vertex(sin(p1Angle) * radius, cylinderHeight, cos(p1Angle) * radius);      
       surface.vertex(sin(p2Angle) * radius, cylinderHeight, cos(p2Angle) * radius);
       surface.vertex(                    0, cylinderHeight,                     0); 

       
    }
    
    surface.endShape(); 
    return surface;
  }
  
  void render(PGraphics layer) {
    layer.pushMatrix();
      layer.translate(position.x, - 0.5 * plate.sizeY - cylinderBaseHeight, position.y);
      layer.shape(shape);
    layer.popMatrix();
  }
}


    