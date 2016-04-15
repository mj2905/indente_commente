import java.util.List;


//Size of the plate
private final int SIZE_Y = 20;
private Plate plate;
//Distance of camera
private final int DEPTH = -200;
private final float gravityConstant = 9.81 * 1/frameRate * 3; //Without the 3 : too slow and unrealistic

private PGraphics gameGraphics;
private PGraphics guiGraphics;
private int guiHeight;
private final float offset_gui = 10;
private int guiElemSize;

private PGraphics plateThumbGraphics;
private float plateRatioThumb;

private PGraphics scoreboardGraphics;
private final float offset_scoreboard = 4;
private float offset_bet_lines;

private PGraphics barChart;
private float widthSquareScore = 4;
private float heightSquareScore = 4;
private final float distanceBetSquares = 1;
private float maxHeightScore = 0;

private static float score = 0;
private static float oldScore = 0;
private float scoreToPrint = 0;

private final List<Float> scores = new ArrayList();
private final int scoresThreshold =  256;



void settings() {
 fullScreen(P3D);
 //size(800,600,P3D);
}

void setup(){
  //frameRate(100);
  guiHeight = height/4;
  
  gameGraphics = createGraphics(width, height - guiHeight, P3D);
  
  gameGraphics.beginDraw();
    gameGraphics.noStroke();
  gameGraphics.endDraw();
  
  guiGraphics = createGraphics(width, guiHeight, P2D);  
  
  guiGraphics.beginDraw();
    guiGraphics.background(#E6E2AF);
  guiGraphics.endDraw();
  
  //To keep a ratio with the screen, avoiding a loss of the plate when in Shift mode
  int SIZE_X_Z = floor(min(gameGraphics.width, gameGraphics.height) * 5.0/6.0);
  plate = new Plate(SIZE_X_Z, SIZE_Y, SIZE_X_Z);
  
  plateRatioThumb = SIZE_X_Z/(guiHeight - offset_gui);
  
  guiElemSize = int(SIZE_X_Z/plateRatioThumb);
  
  
  plateThumbGraphics = createGraphics(guiElemSize, guiElemSize, P2D);
  
  plateThumbGraphics.beginDraw();
    plateThumbGraphics.background(100,0,0);
    plateThumbGraphics.noStroke();
  plateThumbGraphics.endDraw();
  
  
  scoreboardGraphics = createGraphics(guiElemSize, guiElemSize, P2D);
  
  scoreboardGraphics.beginDraw();
    scoreboardGraphics.noStroke();
  scoreboardGraphics.endDraw();
  
  offset_bet_lines = guiElemSize/8;
  
  
  int barWidth = (int)(width - 3 * offset_gui - 2*guiElemSize);
  barChart = createGraphics(barWidth, guiElemSize, P2D);
  barChart.beginDraw();
    barChart.background(#EFECCA);
    barChart.fill(0,0,255);
    barChart.noStroke();
  barChart.endDraw();
  
}

void draw() {
  background(151, 185, 255);
       gameRender();
       
       image(gameGraphics, 0, 0);
       guiRender(0, height - guiHeight);
}
 //<>//
void gameRender() {
   gameGraphics.beginDraw();
       gameGraphics.clear();
       
       if (keyPressed && keyCode == SHIFT) {
          plate.upMode(gameGraphics);
        }
        else {
      // changes to the camera in order to see better what we are doing when angleX>0 
        plate.normalMode(gameGraphics);
        }
       
       gameGraphics.translate(gameGraphics.width/2, gameGraphics.height/2, DEPTH);
       plate.render(gameGraphics);
   gameGraphics.endDraw();
}

void guiRender(int x, int y) {
  image(guiGraphics, x, y);
  plateThumbRender();
  image(plateThumbGraphics, x+ offset_gui/2, y+offset_gui/2);
  scoreboardRender();
  image(scoreboardGraphics, x + offset_gui + guiElemSize + offset_gui/2, y + offset_gui/2);
  barChartRender();
  image(barChart, x + 2*offset_gui + 2*guiElemSize + offset_gui/2, y + offset_gui/2);
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

void plateThumbRender() {
  plateThumbGraphics.beginDraw();
    plateThumbGraphics.pushMatrix();
      plateThumbGraphics.translate(int(plate.getSizeX()/plateRatioThumb)/2, int(plate.getSizeZ()/plateRatioThumb)/2);
      
      PVector positionSphere = plate.getSphere().getPosition();
      PVector oldPositionSphere = plate.getSphere().getOldPosition();
      float diameterSphereThumb = 2 * plate.getSphere().getRadius() / plateRatioThumb;
      
      plateThumbGraphics.fill(75,0,0);
      plateThumbGraphics.ellipse(oldPositionSphere.x/plateRatioThumb, oldPositionSphere.y/plateRatioThumb, diameterSphereThumb, diameterSphereThumb);
      plateThumbGraphics.fill(0,100,0);
      plateThumbGraphics.ellipse(positionSphere.x/plateRatioThumb, positionSphere.y/plateRatioThumb, diameterSphereThumb, diameterSphereThumb);
      
      plateThumbGraphics.fill(0,0,100);
      for(Cylinder c:plate.getCylinders()) {
        PVector positionCylinder = c.getPosition();
        float diameterCylinderThumb = 2*c.getRadius() / plateRatioThumb;
        
        plateThumbGraphics.ellipse(positionCylinder.x/plateRatioThumb, positionCylinder.y/plateRatioThumb, diameterCylinderThumb, diameterCylinderThumb);
      }
    plateThumbGraphics.popMatrix();
  plateThumbGraphics.endDraw();
  
}

void scoreboardRender() {
 scoreboardGraphics.beginDraw();
   scoreboardGraphics.pushMatrix();
     scoreboardGraphics.background(#FFFFFF);
     scoreboardGraphics.fill(#E6E2AF);
     scoreboardGraphics.rect(offset_scoreboard,offset_scoreboard, guiElemSize - 2*offset_scoreboard, guiElemSize - 2*offset_scoreboard);
     scoreboardGraphics.fill(#000000);
     scoreboardGraphics.text("Total Score : ",                           2*offset_scoreboard, 4*offset_scoreboard);
     scoreboardGraphics.text(" " + score,                                2*offset_scoreboard, 4*offset_scoreboard + offset_bet_lines);
     
     scoreboardGraphics.text("Velocity : ",                              2*offset_scoreboard, 4*offset_scoreboard + 3*offset_bet_lines);
     scoreboardGraphics.text(" " + plate.getSphere().getVelocity().mag(),2*offset_scoreboard, 4*offset_scoreboard + 4*offset_bet_lines);
     
     scoreboardGraphics.text("Last Score : ",                            2*offset_scoreboard, 4*offset_scoreboard + 6*offset_bet_lines);
     scoreboardGraphics.text(" " + oldScore,                             2*offset_scoreboard, 4*offset_scoreboard + 7*offset_bet_lines);
     
   scoreboardGraphics.popMatrix();
 scoreboardGraphics.endDraw();
}

void barChartRender() {
 if(scoreToPrint != score) {
   barChart.beginDraw();
   
   if(maxHeightScore < score) {
       maxHeightScore = score;
   }
   
   addWithTreshold(score);
   
   barChart.background(#EFECCA);

   int begin = max(0, (int)(scores.size() - barChart.width/widthSquareScore));
   
   barChart.fill(#0000FF);
   for(int i = begin; i < scores.size(); ++i) {
     int h = (int)((scores.get(i) / maxHeightScore) * barChart.height*0.9);
     h -= h%heightSquareScore;
     float x = (i-begin)*widthSquareScore;
     float y = barChart.height - h;
     
     for(int j = 0; j < h; ++j) {
       
     }
     
     barChart.rect(x,y,widthSquareScore-distanceBetSquares, h);
   }
   
   barChart.fill(#EFECCA);
   for(int i = 0; i < barChart.height/heightSquareScore; ++i) {
     barChart.rect(0, i*heightSquareScore, barChart.width, distanceBetSquares);
   }
   
   

    scoreToPrint = score;
   
   barChart.endDraw();
 }
  
  
}

void addWithTreshold(float score) {
 while(scores.size() >= scoresThreshold) {
   scores.remove(0);
 }
 scores.add(score);
}

void mouseClicked() {
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

public static void addToScore(float addToScore) {
  oldScore = score;
  if(score + addToScore < 0) {
   score = 0; 
  }
  else {
   score += addToScore;
  }
}