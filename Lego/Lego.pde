private PImage img;
private PImage result;
private final int MAX_THRESHOLD = 255;
private int THRESHOLD = 128;
private int PREVIOUS_THRESHOLD = 128;
//private HScrollbar scrollBar;
private HScrollbar scrollBarHueMin;
private HScrollbar scrollBarHueMax;
private int imageHeight;
private final int scrollBarHeight = 20;
private final int offsetScrollBar = 5;

private float oldScrollBarHuePosMin;
private float oldScrollBarHuePosMax;

private int min = 0;
private int max = 255;


void settings() { 
  size(800,600);
}

void setup() {
  imageHeight = height - 2*scrollBarHeight - 3*offsetScrollBar;
 img = loadImage("board1.jpg");
 result = createImage(width, height, RGB);
 //scrollBar = new HScrollbar(0, imageHeight + offsetScrollBar, width, scrollBarHeight);
 scrollBarHueMin = new HScrollbar(0, imageHeight + offsetScrollBar , width, scrollBarHeight);
 scrollBarHueMax = new HScrollbar(0, imageHeight + 2*offsetScrollBar + scrollBarHeight, width, scrollBarHeight);
 oldScrollBarHuePosMin = scrollBarHueMin.getPos();
 oldScrollBarHuePosMax = scrollBarHueMax.getPos();
 //noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() {
 background(0);
 image(result, 0, 0, width, height);
 
 //scrollBar.update();
 //scrollBar.display();
 
 scrollBarHueMin.update();
 scrollBarHueMin.display();
 scrollBarHueMax.update();
 scrollBarHueMax.display();
 
 /*
 PREVIOUS_THRESHOLD = THRESHOLD;
 THRESHOLD = (int)(MAX_THRESHOLD*scrollBar.getPos());
 if(PREVIOUS_THRESHOLD != THRESHOLD) {
  filterBinaryInverted();
 }
 */
 
 if(scrollBarHueMin.getPos() != oldScrollBarHuePosMin) {
  min = (int)(255*scrollBarHueMin.getPos());
  oldScrollBarHuePosMin = scrollBarHueMin.getPos();
  hue(min, max);
 }
 
 if(scrollBarHueMax.getPos() != oldScrollBarHuePosMax) {
  max = (int)(255*scrollBarHueMax.getPos());
  oldScrollBarHuePosMax = scrollBarHueMax.getPos();
  hue(min, max);
 }
 
}

void hue(int min, int max) {
 result.loadPixels();
  for(int i=0; i < img.width* img.height; ++i) {
      int hue = (int)hue(img.pixels[i]);
      result.pixels[i] = (hue >= min && hue <= max) ? img.pixels[i] : color(0);
  }
 result.updatePixels();
}

void filterBinary() {
  result.loadPixels();
  for(int i=0; i < img.width* img.height; ++i) {
    if(brightness(img.pixels[i]) >= THRESHOLD) {
      result.pixels[i] = color(255);
    }
    else {
      result.pixels[i] = color(0); 
    }
  }
  result.updatePixels();
}

void filterBinaryInverted() {
  result.loadPixels();
  for(int i=0; i < img.width * img.height; ++i) {
    if(brightness(img.pixels[i]) < THRESHOLD) {
      result.pixels[i] = color(255);
    }
    else {
      result.pixels[i] = color(0); 
    }
  }  
  result.updatePixels();
  
}