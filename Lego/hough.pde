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
 private PImage houghImg;

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
   
   houghImg = createImage(rDim +2, phiDim +2, ALPHA);
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
  
  void display(){
    houghImg.loadPixels();
     for(int i = 0; i < accumulator.length; i++){
       houghImg.pixels[i] = color(min(255, accumulator[i]));
     }
     
     houghImg.resize(400,400);
     houghImg.updatePixels();
  }
  
  void drawLines(){
     for(int idx = 0; idx < accumulator.length; idx++){
       if(accumulator[idx] > 200){
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
         
         stroke(204,102,0);
         if(y0 > 0){
           if(x1 > 0){
             line(x0,y0,x1,y1);
           }else if(y2 >0){
             line(x0,y0,x2,y2);
           }else{
              line(x0,y0, x3,y3); 
           }
           
         }else{
          if(x1>0){
             if(y2 >0){
                line(x1,y1,x2,y2); 
             }else{
                line(x1,y1,x3,y3); 
             }
            
          } else{ 
            line(x2,y2,x3,y3);
          } 
         }
       }
     }
    
  }
  
}