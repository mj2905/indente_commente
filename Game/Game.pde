private final int SIZE_X = 700, SIZE_Y = 20, SIZE_Z = 700;
private final Plate plate = new Plate(SIZE_X, SIZE_Y, SIZE_Z);
private final int DEPTH = 800;
private float speed = 1.0;
private final float STEP_OF_SPEED = 0.1, MIN_SPEED = 0.2, MAX_SPEED = 5;

void settings() {
 fullScreen(P3D);
 //size(800, 600, P3D);
}

void setup(){
  noStroke();
}

void draw() {
  camera(width/2, height/2, DEPTH, width/2, height/2, 0,0,1.0,0);
  background(151, 185, 255);
  textSize(20);
  printLog(0, 0);
  translate(width/2, height/2, 0);
  plate.render();
}

void printLog(int x, int y) {
  fill(60);
    text("RotationX : " + plate.getRotX(), x, y);
    text("RotationZ : " + plate.getRotZ(), x+400, y);
    text("Speed : " + speed, x+800, y);
}

void mouseDragged() {
  if(mouseY - pmouseY > 0) {
      plate.setRotX(plate.getRotX() - speed);
  } else if(mouseY - pmouseY < 0) {
      plate.setRotX(plate.getRotX() + speed);
  }
  
  if(mouseX - pmouseX > 0) {
      plate.setRotZ(plate.getRotZ() + speed);
  } else if(mouseX - pmouseX < 0) {
      plate.setRotZ(plate.getRotZ() - speed);
  }

}

void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  float tmp = speed + scroll * STEP_OF_SPEED;
  if(tmp > MAX_SPEED) {
    speed = MAX_SPEED;
  }
  else if(tmp < MIN_SPEED) {
     speed = MIN_SPEED; 
  }
  else {
     speed = tmp; 
  }
}

 /*
 To help understanding rotations (right hand rule)
 y
 ^  * z
 | /
 |/
 o----> x
 */