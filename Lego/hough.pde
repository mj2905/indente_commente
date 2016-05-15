class houghTransform {
  // Le nombre de valeurs que phi peut prendre
  final private int maxPhi= 180;

  // L'indice de palliers de phi et l'indice de palliers de R (pour passer d'un rayon continu à un rayon discret, on va devoir tronquer nos cases)
  final private float discretizationStepsPhi = (float)Math.PI / maxPhi; 

  private PImage img;
  private PImage houghImg;

  // Les coordonnées du centre de l'image
  private float centerX, centerY;

  // L'accumulateur, qui stocke une ligne (phi, r) à l'indice phi*rMax + r.
  private int[] accumulator;
  
  // La hauteur de l'accumulateur
  private int houghHeight;

  // On double la hauteur pour prendre les valeurs négatives en plus.
  private int doubleHeight, width, height;

  // On stocke les valeurs de phi possibles, pour gagner des perf'
  private double[] sinCache;
  private double[] cosCache;

  public houghTransform(PImage edgeImg) {
    img = edgeImg;
    this.width = img.width;
    this.height = img.height;
    initialize();
  }
  
  public void initialize(){
     houghHeight = (int) (Math.sqrt(2) * Math.max(height, width))/2;
     doubleHeight = 2*houghHeight;
     accumulator = new int[(maxPhi+2) * (doubleHeight +2 )];
     
     centerX = width /2 ;
     centerY = height/2;
     
     sinCache = new double[maxPhi];
     cosCache = sinCache.clone();
    for (int i = 0; i < maxPhi; i++) {
        double phi = i * discretizationStepsPhi;
        sinCache[i] = Math.sin(phi);
        cosCache[i] = Math.cos(phi);
    }

    houghImg = createImage(doubleHeight +2, maxPhi +2, ALPHA);
  }
  
  int[] getAccumulator() {
    return accumulator;
  }

  public void addPoint(int x,int y){
     int r = 0;
      for(int i = 0; i <maxPhi; i++){
        r = (int) (((x - centerX) * cosCache[i]) + ((y-centerY) * sinCache[i]));
        r += houghHeight;
        if(r < 0 || r > doubleHeight) continue;
        accumulator[i * doubleHeight + r] += 1;
      }
  }

  void fillAccumulator() {
    img.loadPixels();
    accumulator = new int[(maxPhi+2) * (doubleHeight +2 )];
    int r = 0;
    for (int y = 0; y < img.height; ++y) {
      for (int x = 0; x < img.width; ++x) {
        if (brightness(img.pixels[y*img.width + x]) != 0) {
          addPoint(x, y);
        }
      }
    }
    img.updatePixels();
  }
  PImage imageToDisplay(){
    houghImg.loadPixels();
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }

    houghImg.resize(800, 600);
    houghImg.updatePixels();
    return houghImg;
  }

  void display() {
    houghImg.loadPixels();
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }

    houghImg.resize(400, 400);
    houghImg.updatePixels();
  }
/*À mettre à jour*/
  void drawLines() {
    float discretizationStepsR = 2.5f;
    int rDim = (int) (((img.width + img.height)*2 +1)/discretizationStepsR);
    for (int idx = 0; idx < accumulator.length; idx++) {
      if (accumulator[idx] > 20) {
        int accPhi = (int) (idx / (rDim +2)) -1 ;
        int accR = idx - (accPhi + 1) * (rDim +2) -1;
        float r = (accR - (rDim -1) * 0.5f)*discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;

        int x0 = 0;
        int y0 = (int) (r/sin(phi));
        int x1 = (int) (r/cos(phi));
        int y1 = 0;
        int x2 = img.width;
        int y2 = (int) (-cos(phi) / sin(phi) *x2 + r/sin(phi));
        int y3 = img.width;
        int x3 = (int) (-(y3 - r/sin(phi)) * (sin(phi)/cos(phi)));

        stroke(204, 102, 0);
        if (y0 > 0) {
          if (x1 > 0) {
            line(x0, y0, x1, y1);
          } else if (y2 >0) {
            line(x0, y0, x2, y2);
          } else {
            line(x0, y0, x3, y3);
          }
        } else {
          if (x1>0) {
            if (y2 >0) {
              line(x1, y1, x2, y2);
            } else {
              line(x1, y1, x3, y3);
            }
          } else { 
            line(x2, y2, x3, y3);
          }
        }
      }
    }
  }
  
}