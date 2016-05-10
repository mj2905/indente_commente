class houghTransform {
 private int maxPhi= 180;
 private float discretizationStepsPhi; 
 private float discretizationStepsR;
 
 private int phiDim;
 private int rDim;
 
 private PImage img;
 
 private int[] accumulator;
 
 // On stocke les valeurs de theta possibles, pour gagner des perf'
 private double[] sinCache;
 private double[] cosCache;
 
 private int numPoints;
 
 public houghTransform(PImage edgeImg){
   discretizationStepsPhi = (float)Math.PI/ maxPhi;
   discretizationStepsR = 2.5f;
   
   numPoints = 0;
   
   img = edgeImg;
   
   phiDim = (int) (Math.PI/discretizationStepsPhi);
   rDim = (int) (((img.width + img.height)*2 +1)/discretizationStepsR);
   accumulator = new int[(phiDim+2) * (rDim +2)];
   
   sinCache = new double[maxPhi];
   cosCache = sinCache.clone();
   
   // Puisque x = rcos(phi) et y = rsin(phi), on aimerait stocker le cos et le sin quelque part; c'est ici chose faite (les perf')
   for(int i = 0; i < maxPhi; i++){
        double phi = i * discretizationStepsPhi;
        sinCache[i] = Math.sin(phi);
        cosCache[i] = Math.cos(phi);
   }
   
   
 }
 
 int[] getAccumulator(){
    return accumulator; 
 }
 
 void fillAccumulator(){
   img.loadPixels();
   for(int y = 0; y < img.height; ++y){
     for(int x = 0; x < img.width; ++x){
        if(brightness(img.pixels[y*img.width + x]) != 0){
          
        }
     }
   }
 }
  
}