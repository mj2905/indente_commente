public class Cylinder {
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
    PShape openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    for(int i=0; i<cylinderResolution+1; i++) {
      angle = (TWO_PI/cylinderResolution)*i;
      openCylinder.vertex((sin(angle)*this.radius), (cos(angle)*this.radius), 0);
      openCylinder.vertex(sin(angle)*this.radius, cos(angle)*this.radius, this.cylinderHeight);
    }
    openCylinder.endShape();
    PShape surface = createShape();
    surface.beginShape(TRIANGLES);
    for(int i = 0; i < cylinderResolution+1; i++) {
      angle = (TWO_PI/cylinderResolution)*i;
       surface.vertex((sin(angle)*this.radius)+(TWO_PI/cylinderResolution),(cos(angle)*this.radius)+(TWO_PI/cylinderResolution),0);
       surface.vertex((sin(angle)*this.radius), (cos(angle)*this.radius), 0);
       surface.vertex(0,0,0);
       surface.vertex((sin(angle)*this.radius)+(TWO_PI/cylinderResolution),(cos(angle)*this.radius)+(TWO_PI/cylinderResolution),cylinderHeight);
       surface.vertex((sin(angle)*this.radius), (cos(angle)*this.radius), cylinderHeight);
       surface.vertex(0,0,cylinderHeight);
    }
    surface.endShape();
    PShape group = createShape(GROUP);
    group.addChild(openCylinder);
    group.addChild(surface);
    this.shape=group;
  }
  
  void render() {
    pushMatrix();
    fill(255,66,0);
    translate(position.x, this.plate.sizeY*0.5, posistion.y);
    shape(shape);
    popMatrix();
}

    