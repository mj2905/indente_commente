//Size of the plate
private final int SIZE_X = 700, SIZE_Y = 20, SIZE_Z = 700;
private final Plate plate = new Plate(SIZE_X, SIZE_Y, SIZE_Z);
//Distance of camera
private final int DEPTH = 800;
private final float gravityConstant = 9.81 * 1/frameRate * 3; //Without the 3 : too slow and unrealistic


void settings() {
 fullScreen(P3D);
 //size(800, 600, P3D);
}

void setup(){
  noStroke();
}

void draw() {
  
  //camera(width/2, height/2, DEPTH, width/2, height/2, 0,0,1.0,0);
  background(151, 185, 255);
  //translate(width/2, height/2, 0);
  
  if (keyPressed && keyCode == SHIFT) {
        camera(width/2, height/2, DEPTH, width/2, height/2, 0,0,1.0,0);
        translate(width/2, height/2, 0);
        plate.noUpdateRender();
  }
  else {
      // changes to the camera in order to see better what we are doing when angleX>0
      camera(width/2, -height/8, DEPTH, width/2, height/2, 0,0,1.0,0); 
      translate(width/2, height/2, 0);
      plate.render();
    }
}

void printLog(int x, int y) {
  fill(60);
    textSize(20);
    text("RotationX : " + plate.getRotX(), x, y);
    text("RotationZ : " + plate.getRotZ(), x+400, y);
    text("Speed : " + plate.getSpeed(), x+800, y);
}

void mouseClicked() {
 plate.addCylinder();
}

void mouseDragged() {
  if (plate.normalMode) {
    if(mouseY - pmouseY > 0) {
        plate.setRotX(plate.getRotX() - plate.getSpeed());
    } else if(mouseY - pmouseY < 0) {
        plate.setRotX(plate.getRotX() + plate.getSpeed());
    }
    
    if(mouseX - pmouseX > 0) {
        plate.setRotZ(plate.getRotZ() + plate.getSpeed());
    } else if(mouseX - pmouseX < 0) {
        plate.setRotZ(plate.getRotZ() - plate.getSpeed());
    }
  }

}

void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  plate.setSpeed(plate.getSpeed() + scroll * plate.STEP_OF_SPEED);
}