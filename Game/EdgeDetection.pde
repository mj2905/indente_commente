  import processing.video.*;
  import java.util.*;

class ImageProcessing extends PApplet {

  //Modify the path here :
  private Movie movieCam = new Movie(this, "C:/Users/Marc/Documents/VisualProgramming/indente_commente/Game/data/testvideo.mp4");

  TwoDThreeD d2d3;
  PVector rotations= new PVector(0,0,0);
  
  private PImage img;
  private PImage result;
  private int THRESHOLD = 130; //165
  
  PGraphics imgEdgeDetector;
  
  private boolean pause = false;
  
  public void setPause(boolean pause) {
     this.pause = pause; 
  }
  
  //private boolean playing = true;
  //private boolean pauseWhenPossible = false;
  
  /*
    void keyPressed() {
    if(key == 'q') {println("saturation " + saturationThreshold); saturationThreshold++;}
    if(key == 'a') {println("saturation " + saturationThreshold); saturationThreshold--;}
    if(key == 'w') {println("brightness " + brightnessThreshold); brightnessThreshold++;}
    if(key == 's') {println("brightness " + brightnessThreshold); brightnessThreshold--;}
    if(keyCode == UP) {println("hueMax " + hueMax); hueMax++;}
    if(keyCode == DOWN) {println("hueMax " + hueMax); hueMax--;}
    if(keyCode == RIGHT) {println("hueMin " + hueMin); hueMin++;}
    if(keyCode == LEFT) {println("hueMin " + hueMin); hueMin--;}
    if(key == 'd') {println("THRESHOLD " + THRESHOLD); THRESHOLD--;}
    if(key == 'e') {println("THRESHOLD " + THRESHOLD); THRESHOLD++;}
    if(key == 'f') {println("Min_Area " + minArea); minArea--;}
    if(key == 'r') {println("Min_Area " + minArea); minArea++;}
    if(key == 'g') {println("maxArea " + maxArea); maxArea--;}
    if(key == 't') {println("maxArea " + maxArea); maxArea++;}
    if(key == 'p') {if(playing) {playing = false; movieCam.pause();} else {playing = true; movieCam.play();}}
    if(key == 'n') {pauseWhenPossible = !pauseWhenPossible;}
  }
  */
  
  private int brightnessThreshold = 50;
  private int saturationThreshold = 70;
  private int hueMin = 75;
  private int hueMax = 127;
  private int minArea = 100;
  private int maxArea = 10000000;
  
  PVector getRotation() {
    return rotations;
  }
  
  void settings() { 
    size(200,150);
  }
  
  void setup() {
    
   surface.setAlwaysOnTop(true);
   surface.setLocation(0,0);
   surface.setResizable(false);
   
   d2d3 = new TwoDThreeD(800, 600);

   movieCam.loop();
   
   imgEdgeDetector = createGraphics(800,600);
   
   //String[] cameras = Capture.list();
   //cam = new Capture(this, cameras[0]);
   //cam.start();
  }
  
  void draw() {
      if(!pause) {
        imgproc.update();
      }
      image(imgEdgeDetector, 0, 0, width, height);
    }

  void update() {
      if (movieCam.available()){ //|| !playing) {
         background(0);
         //if(playing) {
           movieCam.read();
         //}
         img=movieCam;
         //img = loadImage("C:/Users/Marc/Documents/VisualProgramming/indente_commente/Game/board4.jpg"); 
          
         imgEdgeDetector = createGraphics(img.width,img.height); 
          
         result = sobel(filterBinaryMutable(gaussianConvolute(thresholdBrightnessSaturationHue(img)), THRESHOLD));
         
         QuadGraph graph = new QuadGraph();
         HoughCorner hough = new HoughCorner(result, 180, 7, 20);
         
         List<PVector> lines = hough.getBestEdges();
         
         graph.build(lines,img.width,img.height);
         
         List<PVector> edgesToPrint = new ArrayList(graph.bestCycles(lines, maxArea, minArea));
         
         imgEdgeDetector.beginDraw();
           imgEdgeDetector.clear();
         
           imgEdgeDetector.image(img, 0, 0);
           hough.drawEdges(imgEdgeDetector, edgesToPrint);
           
           List<PVector> intersections = new ArrayList(graph.bestCyclesNodes(lines,maxArea,minArea));//hough.getIntersections(edgesToPrint);
           
           hough.drawIntersections(imgEdgeDetector, intersections);
           if (intersections.size()>= 4) {
             rotations = d2d3.get3DRotations(intersections);
             //println("rx : " + degrees(rotations.x) + " ry : " + degrees(rotations.y) + " rz : " + degrees(rotations.z));
           }
           else {
            //playing = false; movieCam.pause();
           }
         imgEdgeDetector.endDraw();
          
         //image(hough.getHough(), 400, 0, 400, 300);
         //image(result, 800, 0, 400, 300);
         
         //if(pauseWhenPossible) {
         //  playing = false; movieCam.pause();
         //}
      } 
  }
  
  

  
  
  
  PImage thresholdBrightnessSaturationHue(PImage image) {
   PImage resultImage = createImage(image.width,image.height,ALPHA);
   
   for(int i=0; i < resultImage.width; ++i) {
      for(int j=0; j < resultImage.height; ++j) {
        //25 80
          color c = image.pixels[i + j*resultImage.width];
        
          if(brightness(c) < brightnessThreshold || saturation(c) < saturationThreshold) {
             resultImage.pixels[i + j * resultImage.width] =  color(0);
          }
          else {
             float hue = hue(c);
             //95 139
              resultImage.pixels[i + j * resultImage.width] =  (hue >= hueMin  && hue <= hueMax) ? color(255) : color(0);
          }
      }
   }
   return resultImage;
  }
  
  PImage thresholdBrightnessSaturationHueMutable(PImage image) {
   
   for(int i=0; i < image.width; ++i) {
      for(int j=0; j < image.height; ++j) {
        
        color c = image.pixels[i + j*image.width];
        
          if(brightness(c) < brightnessThreshold || saturation(c) < saturationThreshold) {
             image.pixels[i + j * image.width] =  color(0);
          }
          else {
             float hue = hue(c);
              image.pixels[i + j * image.width] =  (hue >= hueMin  && hue <= hueMax) ? color(255) : color(0);
          }
      }
   }
   return image;
  }
  
  /***************
  ** Utility methods
  ****************/
  
  PImage hueImage(PImage image, int min, int max) {
   PImage resultImage = createImage(image.width,image.height,ALPHA);

    for(int i=0; i < image.width* image.height; ++i) {
        float hue = hue(image.pixels[i]);
        resultImage.pixels[i] = (hue >= min && hue <= max) ? image.pixels[i] : color(0);
    }

   return resultImage;
  }
  
  PImage hueImageMutable(PImage image, int min, int max) {

    for(int i=0; i < image.width* image.height; ++i) {
        float hue = hue(image.pixels[i]);
        image.pixels[i] = (hue >= min && hue <= max) ? image.pixels[i] : color(0);
    }

   return image;
  }
  
  PImage filterBinary(PImage image, float threshold) {
    PImage resultImage = createImage(image.width,image.height,ALPHA);

    for(int i=0; i < image.width* image.height; ++i) {
      if(brightness(image.pixels[i]) >= threshold) {
        resultImage.pixels[i] = color(255);
      }
      else {
        resultImage.pixels[i] = color(0); 
      }
    }
    
    return resultImage;
  }
  
  PImage filterBinaryMutable(PImage image, float threshold) {

    for(int i=0; i < image.width* image.height; ++i) {
      if(brightness(image.pixels[i]) >= threshold) {
        image.pixels[i] = color(255);
      }
      else {
        image.pixels[i] = color(0); 
      }
    }
    
    return image;
  }
  
  PImage filterBinaryInverted(PImage image, float threshold) {
    PImage resultImage = createImage(image.width,image.height,ALPHA);

    for(int i=0; i < image.width * image.height; ++i) {
      if(brightness(image.pixels[i]) < threshold) {
        resultImage.pixels[i] = color(255);
      }
      else {
        resultImage.pixels[i] = color(0); 
      }
    }  

    return resultImage;
  }
  
  PImage filterBinaryInvertedMutable(PImage image, float threshold) {

    for(int i=0; i < image.width * image.height; ++i) {
      if(brightness(image.pixels[i]) < threshold) {
        image.pixels[i] = color(255);
      }
      else {
        image.pixels[i] = color(0); 
      }
    }  

    return image;
  }
  
  
  /**********************
  ** Convolution methods
  ***********************/
  
  
  PImage convolution(PImage image, float[][] kernel, float weight) {
    // create a greyscale image (type: ALPHA) for output
    PImage resultImage = createImage(image.width, image.height, ALPHA);
    
      for(int i=1; i < image.width-1; ++i) {
        for(int j=1; j < image.height-1; ++j) {
          resultImage.pixels[i + j * image.width] = (maskValue(i, j, kernel, weight, image));
        }
      }
  
    return resultImage;
  }
  
  
  PImage convolute(PImage image) {
    float[][] kernel = { { 0, 1, 0 },
                        { 1, 0, 1 },
                        { 0, 1, 0 }};
    return convolution(image, kernel, 4);
  }
  
  PImage gaussianConvolute(PImage image){
    float[][] kernel = { {9,12,9},{12,15,12}, {9,12,9}};
    return convolution(image, kernel, 99);
  }
  
  int maskValueSumH(int i, int j, float weight, PImage image) {
          return color((int)((brightness(image.pixels[i + (j-1) * image.width]) - brightness(image.pixels[i + (j+1) * image.width]))/weight));
  }
  
  int maskValueSumV(int i, int j, float weight, PImage image) {
          return color((int)((brightness(image.pixels[i-1 + j * image.width]) - brightness(image.pixels[i+1 + j * image.width]))/weight));
  }
  
  int maskValue(int i, int j, float[][] mask, float weight, PImage image) {

          float bright = 0;
          for(int x=-1; x <=1; ++x) {
            for(int y=-1; y <=1; ++y) {
                bright += brightness(image.pixels[i+x + (j+y) * image.width]) * mask[x+1][y+1];
            }  
          }
        return color((int)(bright/weight));
  }
  
  
  
  /*********************
  ** Sobel method
  **********************/
  
  
  PImage sobel(PImage image) {
    float[][] hKernel = { { 0,  1, 0 },
                          { 0,  0, 0 },
                          { 0, -1, 0 } };
    float[][] vKernel = { { 0,  0,  0 },
                          { 1,  0, -1 },
                          { 0,  0,  0  } };
    PImage resultImage = createImage(image.width, image.height, ALPHA);
    
    color sumh = color(0);
    color sumv = color(0);
    color sum = color(0);
    
    float max=0;
    float[] buffer = new float[image.width * image.height];
    // *************************************
    // Implement here the double convolution
    // *************************************
    for (int y = 2; y < image.height - 2; y++) {
    // Skip top and bottom edges
      for (int x = 2; x < image.width - 2; x++) {
        // Skip left and right
        
        //sumh = maskValue(x,y, hKernel,1, image);
        //sumv = maskValue(x,y, vKernel, 1, image);
        
        sumh = maskValueSumH(x,y,1,image);
        sumv = maskValueSumV(x,y,1,image);
        
        sum = (int)(sqrt(pow(brightness(sumh),2) + pow(brightness(sumv),2)));
        //sum = (int)(sqrt(pow(sumh,2) + pow(sumv ,2)));
        buffer[x + y*image.width] = sum;
        
        max = max(max, sum);
      }
    }
    
    for (int y = 0; y < image.height; y++) {
    // Skip top and bottom edges
      for (int x = 0; x < image.width; x++) {
        // Skip left and right
        if(y <= 2 || y >= image.height - 2 || x <= 2 || x >= image.width -2) {
            resultImage.pixels[x + y * image.width] = color(0);
        }
        else {
          if (buffer[x + y * image.width] > (int)(max * 0.3f)) {
            // 30% of the max
            resultImage.pixels[x + y * image.width] =  color(255);
            } 
          else {
            resultImage.pixels[x + y * image.width] = color(0);
          }
        }
      }
    }
  return resultImage;
  }
}