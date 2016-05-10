class houghTransform {
  // Le nombre de valeurs que phi peut prendre
 private int maxPhi= 180;
 
 // L'indice de palliers de phi et l'indice de palliers de R (pour passer d'un rayon continu à un rayon discret, on va devoir tronquer nos cases)
 private float discretizationStepsPhi; 
 private float discretizationStepsR;
 
 private int phiDim;
 private int rDim;
 
 // Le rayon maximal, utilisé dans l'indexation de l'accumulateur
 private int rMax;
 
 
 private PImage img;

 private int centerX;
 private int centerY;
 
 // L'accumulateur, qui stocke une ligne (phi, r) à l'indice phi*rMax + r.
 private int[] accumulator;
 
 // On stocke les valeurs de phi possibles, pour gagner des perf'
 private double[] sinCache;
 private double[] cosCache;
 
 public houghTransform(PImage edgeImg){
   discretizationStepsPhi = (float)Math.PI/ maxPhi;
   discretizationStepsR = 2.5f;
   
   img = edgeImg;
   
   centerX = img.width/2;
   centerY = img.height/2;
   
   rMax = (int)Math.sqrt(img.width*img.width+ img.height*img.height); // Clairement, la diagonale est le rMax
   
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
   double r = 0;
   double recenter = (rDim-1)/2;
   double tmps = 0;
   for(int y = 0; y < img.height; ++y){
     for(int x = 0; x < img.width; ++x){
        if(brightness(img.pixels[y*img.width + x]) != 0){
          for(int i = 0; i < maxPhi; i++){ // Pour toutes les variations de phi possibles
             r = x/cosCache[i]; // puisque x = rcos(phi), alors r = x/cos(phi).
             r += recenter; // On recentre ici, pour le cas des valeurs négatives (le cos qui donne -1)
             tmps = Math.floor(r); // Une valeur temporaire ( pour les perfs et éviter de refaire les floor plus bas)
             r = ((tmps + discretizationStepsR) > r)? tmps : tmps+1; // Si  entier(r) < r < entier(r) + pallier, alors r = entier(r), sinon r = entier(r) + 1 pour les indices.
             accumulator[i * rMax + (int)r] += 1;
          }
          

        }
     }
   }
   img.updatePixels();
 }
  
}