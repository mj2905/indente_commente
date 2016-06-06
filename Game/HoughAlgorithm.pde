public class HoughAlgorithm {
 
  private final PImage edgeImg;
  private final float discretizationStepsPhi = 0.01f;
  private final float discretizationStepsR = 2.5f;
  
  //dimensions of the accumulator
  private final int phiDim;
  private final int rDim;
  
  // On stocke les valeurs de phi possibles, pour gagner des perf'
   public double[] sinCache;
   public double[] cosCache;
  
  public HoughAlgorithm(PImage edgeImg) {
    this.edgeImg = edgeImg;
    
    phiDim = (int) (Math.PI / discretizationStepsPhi);
    rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    
     cosCache = new double[phiDim];
     sinCache = new double[phiDim];
     
     for (int i = 0; i < phiDim; i++) {
        double phi = i * discretizationStepsPhi;
        sinCache[i] = Math.sin(phi);
        cosCache[i] = Math.cos(phi);
     }
  }
  
  PImage getHough(int[] accumulator) {
    PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    for(int i=0; i < accumulator.length; ++i) {
     houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    houghImg.resize(800,600);
    houghImg.updatePixels();
    return houghImg;
  }
  
  private int[] accumulatorBuffer;
  private boolean accumulatorComputed = false;
  
  public int[] getAccumulator() {
     if(!accumulatorComputed) {
        accumulatorBuffer = fillAccumulator();
        accumulatorComputed = true;
     }
     return accumulatorBuffer;
  }
  
  private int[] fillAccumulator() {
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    //Fill the accumulator: on edge points (ie, white pixels of the edge image),
    //store all possible (r, phi) pairs describing lines going through the point.
    for(int y = 0; y < edgeImg.height; ++y) {
     for(int x = 0; x < edgeImg.width; ++x) {
      //Are we on an edge?
      if(brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for(int i = 0; i < phiDim; ++i) {
          int r = (int)((x * cosCache[i] + y * sinCache[i]) / discretizationStepsR);
          r+= (rDim-1)/2;
          ++accumulator[(i+1) * (rDim + 2) + r + 2];
        }
      }
     }
    }
    return accumulator;
  }
  
  
}