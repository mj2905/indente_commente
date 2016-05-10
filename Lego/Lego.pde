  private PImage img;
  private PImage result;
  private PImage aux;
  private final int MAX_THRESHOLD = 255;
  private int THRESHOLD = 128;
  private int PREVIOUS_THRESHOLD = 128;
  //private HScrollbar scrollBar;
  private HScrollbar scrollBarHueMin;
  private HScrollbar scrollBarHueMax;
  private int imageHeight;
  private final int scrollBarHeight = 20;
  private final int offsetScrollBar = 5;
  
  private float oldScrollBarHuePosMin = 0;
  private float oldScrollBarHuePosMax = 0;
  
  private int min = 0;
  private int max = 255;
  
  
  void settings() { 
    size(800,600);
  }
  
  void setup() {
    imageHeight = height - 2*scrollBarHeight - 3*offsetScrollBar;
   img = loadImage("board1.jpg");
   result = createImage(width, height, RGB);
   aux = createImage(width, height, RGB);
   
   //scrollBar = new HScrollbar(0, imageHeight + offsetScrollBar, width, scrollBarHeight);
   scrollBarHueMin = new HScrollbar(0, imageHeight + offsetScrollBar , width, scrollBarHeight);
   scrollBarHueMax = new HScrollbar(0, imageHeight + 2*offsetScrollBar + scrollBarHeight, width, scrollBarHeight);
   //noLoop(); // no interactive behaviour: draw() will be called only once.
  }
  
  void draw() {
   background(0);
   image(result, 0, 0, width, height);
   
   scrollBarHueMin.update();
   scrollBarHueMin.display();
   scrollBarHueMax.update();
   scrollBarHueMax.display();
   
   if(scrollBarHueMin.getPos() != oldScrollBarHuePosMin) {
    min = (int)(255*scrollBarHueMin.getPos());
    oldScrollBarHuePosMin = scrollBarHueMin.getPos();
    hue(img, min, max, result);
    convolute(result);
    sobel(result);
   }
   else if(scrollBarHueMax.getPos() != oldScrollBarHuePosMax) {
    max = (int)(255*scrollBarHueMax.getPos());
    oldScrollBarHuePosMax = scrollBarHueMax.getPos();
    hue(img, min, max, result);
    convolute(result);
    sobel(result);
   }
   
  }
  
  
  /***************
  ** Utility methods
  ****************/
  
  PImage hue(PImage img, int min, int max, PImage result) {
   //PImage result = createImage(img.width, img.height, ALPHA);
   result.loadPixels();
    for(int i=0; i < img.width* img.height; ++i) {
        int hue = (int)hue(img.pixels[i]);
        result.pixels[i] = (hue >= min && hue <= max) ? img.pixels[i] : color(0);
    }
   result.updatePixels();
   return result;
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
  
  PImage filterBinaryInverted(PImage result) {
    
    result.loadPixels();
    for(int i=0; i < result.width * result.height; ++i) {
      if(brightness(result.pixels[i]) < THRESHOLD) {
        result.pixels[i] = color(255);
      }
      else {
        result.pixels[i] = color(0); 
      }
    }  
    result.updatePixels();
    return result;
  }
  
  
  /**********************
  ** Convolution methods
  ***********************/
  
  
  PImage convolution(PImage img, float[][] kernel) {
    float weight = 4f;
    // create a greyscale image (type: ALPHA) for output
   // PImage result = createImage(img.width, img.height, ALPHA);
    
    result.loadPixels();
      for(int i=1; i < img.width-1; ++i) {
        for(int j=1; j < img.height-1; ++j) {
          result.pixels[j*img.width + i] = maskValue(i, j, kernel, weight,  img);
        }
      }
    result.updatePixels();
  
    return result;
  }
  
  
  PImage convolute(PImage img) {
    float[][] kernel = { { 0, 1, 0 },
                        { 1, 0, 1 },
                        { 0, 1, 0 }};
    return convolution(img, kernel);
  }
  
  PImage gaussianConvolute(PImage img){
    float[][] kernel = { {9,12,9},{12,15,12}, {9,12,9}};
    return convolution(img, kernel);
  }
  
  
  color maskValue(int i, int j, float[][] mask, float weight, PImage img) {
          int r=0, g=0, b=0;
          for(int x=-1; x <=1; ++x) {
            for(int y=-1; y <=1; ++y) {
                color c = img.get(i+x, j+y);
                r += ((c >> 16) & 0xFF) * mask[x+1][y+1];
                g += ((c >> 8) & 0xFF) * mask[x+1][y+1];
                b += (c & 0xFF) * mask[x+1][y+1];
            }  
          }
          
          r=(int) (r/weight);
          g=(int) (g/weight);
          b= (int) (b/weight);
          
          r = (r>255) ? 255 : r;
          g = (g>255) ? 255 : g;
          b = (b>255) ? 255 : b;
          
        return color(r, g, b);
  }
  
  
  /*********************
  ** Sobel method
  **********************/
  
  
  PImage sobel(PImage img) {
    float[][] hKernel = { { 0,  1, 0 },
                          { 0,  0, 0 },
                          { 0, -1, 0 } };
    float[][] vKernel = { { 0,  0,  0 },
                          { 1,  0, -1 },
                          { 0,  0,  0  } };
    //PImage result = createImage(img.width, img.height, ALPHA);
    result.loadPixels();
    // clear the image
    /*for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }*/
    
    color sumh = color(0);
    color sumv = color(0);
    color sum = color(0);
    
    float max=0;
    float[] buffer = new float[img.width * img.height];
    // *************************************
    // Implement here the double convolution
    // *************************************
    for (int y = 2; y < img.height - 2; y++) {
    // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) {
        // Skip left and right
        
        sumh = maskValue(x,y,hKernel,1, img);
        sumv = maskValue(x,y,vKernel,1, img);
        
        sum = (int)(sqrt(pow(brightness(sumh),2) + pow(brightness(sumv),2)));
        //sum = (int)(sqrt(pow(sumh,2) + pow(sumv ,2)));
        buffer[x + y*img.width] = sum;
        
        max = max(max, sum);
      }
    }
    
    for (int y = 2; y < img.height - 2; y++) {
    // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) {
        // Skip left and right
        
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) {
          // 30% of the max
          result.pixels[y * img.width + x] = color(255);
          } 
        else {
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
    result.updatePixels();
    return result;
  }