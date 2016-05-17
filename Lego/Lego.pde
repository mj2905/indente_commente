  import processing.video.*;
  import java.util.*;
  
  private PImage img;
  private PImage result;
  private int THRESHOLD = 185; //165
  
  private Capture cam;
  private PImage cameraImg;

  
  void settings() { 
    size(800,600);
  }
  
  void setup() {
   img = loadImage("board1.jpg");
   //noLoop();
   /*
   String[] cameras = Capture.list();
   if(cameras.length == 0){
    println("No camera available");
    exit();
   }else{
      println("Available cameras:");
     for(int i = 0; i <cameras.length; i++){
        println(cameras[i]); 
     } 
     cam = new Capture(this, cameras[0]);
     cam.start();
   }*/
   
   result = sobel(filterBinaryMutable(gaussianConvolute(thresholdBrightnessSaturationHue(img)), THRESHOLD));
   houghCandidates h = new houghCandidates(result, 200, 100, 10);
   //h.fillCandidates();
   image(result, 0, 0);
   QuadGraph quadgraph = new QuadGraph();
   List<PVector> lines = h.createLines();
   println(lines);
   quadgraph.build(lines,width, height);
   println(quadgraph.findCycles());
   List<PVector> bestOfCycles = new ArrayList(quadgraph.bestCycles(lines, quadgraph.findCycles(),0,0));
   h.drawEdges(bestOfCycles);
   //List<PVector> points = h.getIntersections(h.fillEdges());
   /*println(points);
      fill(255,0,0);
   for(PVector point : points) {
     ellipse(point.x, point.y, 100, 100);
   }*/
   
   //houghCandidates h3  = new houghCandidates(result, 200, 4, 10);
  }
  
  void draw() {
   //background(0);
     //houghCandidates h3  = new houghCandidates(result, 200, 200, 10);

   
   
   /*
     if(cam.available() == true){
         cam.read(); 
         cameraImg = cam.get();
         image(sobel(thresholdLowValues(cameraImg)),0,0);
     }*/
     //HoughCorner h = new HoughCorner(result, 3, 6, 4);
     //houghTransform h = new houghTransform(result);
     //h.fillAccumulator();
     //PImage imgtemp = h.imageToDisplay();
     //image(result,0,0);
     //h.drawLines();
      //image(result, 0, 0);
      //h3.drawEdges();
      
  //}
    
  }
  
  PImage thresholdBrightnessSaturationHue(PImage image) {
   PImage resultImage = createImage(image.width,image.height,ALPHA);
   
   for(int i=0; i < resultImage.width; ++i) {
      for(int j=0; j < resultImage.height; ++j) {
          if(brightness(image.pixels[i + j*resultImage.width]) < 25 || saturation(image.pixels[i + j*resultImage.width]) < 80) {
             resultImage.pixels[i + j * resultImage.width] =  color(0);
          }
          else {
             float hue = hue(image.pixels[i + j*resultImage.width]);
              resultImage.pixels[i + j * resultImage.width] =  (hue >= 95  && hue <= 139) ? color(255) : color(0);
          }
      }
   }
   return resultImage;
  }
  
  PImage thresholdBrightnessSaturationHueMutable(PImage image) {
   
   for(int i=0; i < image.width; ++i) {
      for(int j=0; j < image.height; ++j) {
          if(brightness(image.pixels[i + j*image.width]) < 25 || saturation(image.pixels[i + j*image.width]) < 80) {
             image.pixels[i + j * image.width] =  color(0);
          }
          else {
             float hue = hue(image.pixels[i + j*image.width]);
              image.pixels[i + j * image.width] =  (hue >= 95  && hue <= 139) ? color(255) : color(0);
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
        
        sumh = maskValue(x,y,hKernel,1, image);
        sumv = maskValue(x,y,vKernel,1, image);
        
        sum = (int)(sqrt(pow(brightness(sumh),2) + pow(brightness(sumv),2)));
        //sum = (int)(sqrt(pow(sumh,2) + pow(sumv ,2)));
        buffer[x + y*image.width] = sum;
        
        max = max(max, sum);
      }
    }
    
    for (int y = 2; y < image.height - 2; y++) {
    // Skip top and bottom edges
      for (int x = 2; x < image.width - 2; x++) {
        // Skip left and right
        
        if (buffer[x + y * image.width] > (int)(max * 0.3f)) {
          // 30% of the max
          resultImage.pixels[x + y * image.width] =  color(255);
          } 
        else {
          resultImage.pixels[x + y * image.width] = color(0);
        }
      }
    }
  return resultImage;
}