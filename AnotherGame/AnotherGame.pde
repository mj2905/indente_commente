//Size of the plate
private final int SIZE_X = 700, SIZE_Y = 20, SIZE_Z = 700;
private PImage imgPlaque;
private PImage imgSphere;
//private YetAnotherSphere s;
private AnotherPlate plate;
//Distance of camera
private final int DEPTH = 800;
private final float gravityConstant = 1;

void settings() {
 size(500,500,P3D);
}

void setup(){
  noStroke();
  PImage imgSphere = loadImage("opale.jpg");
  PImage imgPlaque = loadImage("emerald.jpg");
  textureMode(NORMAL);
  // On initialise la plaque et la bouboule en même temps dans le SETUP pour pouvoir lui passer les images de textures, qui doivent être initialisées ici et pas avant.
  plate = new AnotherPlate(SIZE_X, SIZE_Y, SIZE_Z, imgPlaque, imgSphere); 
  //s = new YetAnotherSphere(createShape(SPHERE, 30), imgSphere, plate, 30);
}

void draw() {
  camera(width/2, height/2, DEPTH, width/2, height/2, 0,0,1.0,0);
  background(151, 185, 255);
  printLog(0, 0);
  translate(width/2, height/2, 0);
  plate.render();
 // s.render();
}

void printLog(int x, int y) {
  fill(60);
    textSize(20);
    text("RotationX : " + plate.getRotX(), x, y);
    text("RotationZ : " + plate.getRotZ(), x+400, y);
    text("Speed : " + plate.getSpeed(), x+800, y);
}

void mouseDragged() {
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

void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  plate.setSpeed(plate.getSpeed() + scroll * plate.STEP_OF_SPEED);
}