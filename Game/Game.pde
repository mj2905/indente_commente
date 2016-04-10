//Size of the plate
private final int SIZE_Y = 20;
private Plate plate;
//Distance of camera
private final int DEPTH = -200;
private final float gravityConstant = 9.81 * 1/frameRate * 3; //Without the 3 : too slow and unrealistic

private PGraphics gameGraphics;
private PGraphics guiGraphics;
private int guiHeight;


void settings() {
 fullScreen(P3D);
 //size(800,600,P3D);
}

void setup(){
  noStroke();
  guiHeight = height/8;
  gameGraphics = createGraphics(width, height - guiHeight, P3D);
  guiGraphics = createGraphics(width, guiHeight, P3D);
  
  //To keep a ratio with the screen, avoiding a loss of the plate when in Shift mode
  int SIZE_X_Z = floor(min(gameGraphics.width, gameGraphics.height) * 5.0/6.0);
  plate = new Plate(SIZE_X_Z, SIZE_Y, SIZE_X_Z);
  
  
}

void draw() {
  println(mouseY);
  background(151, 185, 255);
       gameRender();
       guiRender();
       
       image(gameGraphics, 0, 0);
       image(guiGraphics, 0, height - guiHeight);
}

void gameRender() {
   gameGraphics.beginDraw();
       gameGraphics.clear();
       gameGraphics.noStroke();
       
       if (keyPressed && keyCode == SHIFT) {
          plate.upMode(gameGraphics);
        }
        else {
      // changes to the camera in order to see better what we are doing when angleX>0 
        plate.normalMode(gameGraphics);
        }
       
       gameGraphics.translate(width/2, height/2, DEPTH);
       plate.render(gameGraphics);
   gameGraphics.endDraw();
}

void guiRender() {
  guiGraphics.beginDraw();
    guiGraphics.clear();
    guiGraphics.background(#996F3C);
  guiGraphics.endDraw();
}

/* For debug
void printLog(int x, int y) {
  fill(60);
    textSize(20);
    text("RotationX : " + plate.getRotX(), x, y);
    text("RotationZ : " + plate.getRotZ(), x+400, y);
    text("Speed : " + plate.getSpeed(), x+800, y);
    text("SpeedSphere : " + plate.sphere.speed.x, x + 1000, y);
}
*/

void mouseClicked() { //<>//
     plate.addCylinder(gameGraphics);
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