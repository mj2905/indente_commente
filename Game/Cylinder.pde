public class Cylinder {
  private final float cylinderBaseSize = 50;
  private final float cylinderBaseHeight = 50;
  private final int cylinderBaseResolution = 40;
  private Plate plate;
  private final float radius;
  private final PVector position;
  private PShape shape;
  private int cylinderResolution;
  private float cylinderHeight;
  
  Cylinder(Plate plate, PVector position, float r, float cylinderHeight, int cylinderResolution) {
    this.plate = plate;
    this.radius = r;
    this.cylinderResolution = cylinderResolution;
    this.cylinderHeight = cylinderHeight;
    this.position = position;
    float angle;
    float angle2;
    PShape openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    openCylinder.fill(255,66,0);
    for(int i=0; i<cylinderResolution+1; i++) {
      angle = (TWO_PI/cylinderResolution)*i;
      openCylinder.vertex((sin(angle)*this.radius), 0, (cos(angle)*this.radius));
      openCylinder.vertex(sin(angle)*this.radius, this.cylinderHeight, cos(angle)*this.radius);
    }
    openCylinder.endShape();
    PShape surface = createShape();
    surface.beginShape(TRIANGLES);
    surface.fill(255,66,0);
    for(int i = 0; i < cylinderResolution+1; i++) {
      angle = (TWO_PI/cylinderResolution)*i;
      angle2 = (TWO_PI/cylinderResolution)*(i+1);
       surface.vertex(sin(angle2)*this.radius,0, cos(angle2)*this.radius);
       surface.vertex(sin(angle)*this.radius, 0, cos(angle)*this.radius);
       surface.vertex(0,0,0);
       surface.vertex(sin(angle2)*this.radius,cylinderHeight, cos(angle2)*this.radius);
       surface.vertex(sin(angle)*this.radius, cylinderHeight, cos(angle)*this.radius);
       surface.vertex(0,cylinderHeight,0);
    }
    surface.endShape();
    PShape group = createShape(GROUP);
    group.addChild(openCylinder);
    group.addChild(surface);
    this.shape=group;
  }
  
  Cylinder(Plate plate, PVector position) {
    this(plate, position, 50, 50, 40);
  }
  
  void render() {
    pushMatrix();
    //fill(255,66,0);
    translate(position.x, -this.plate.sizeY*0.5-this.cylinderBaseHeight, position.y);
    shape(shape);
    popMatrix();
  }
}

    