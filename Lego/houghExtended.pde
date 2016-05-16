class houghCandidates extends houghTransform{
  final private int maxPhi= 180;

  // L'indice de palliers de phi et l'indice de palliers de R (pour passer d'un rayon continu à un rayon discret, on va devoir tronquer nos cases)
  final private float discretizationStepsPhi = (float)Math.PI / maxPhi; 

  // Respectivement l'image où l'on applique la transformation et l'image représentant l'accumulateur
  //private PImage img;
  //private PImage houghImg;

  // Les coordonnées du centre de l'image
  //private float centerX, centerY;

  // L'accumulateur, qui stocke une ligne (phi, r) à l'indice phi*rMax + r.
  //private int[] accumulator;
  
  // La hauteur de l'accumulateur
  //private int houghHeight;

  // On double la hauteur pour prendre les valeurs négatives en plus.
  //private int doubleHeight, width, height;

  // On stocke les valeurs de phi possibles, pour gagner des perf'
  //private double[] sinCache;
  //private double[] cosCache;
  
  // Le nombre de lignes est stocké dans un tableau
  private int nbLines, minVotes, neighbourhoodSize;
  
  private ArrayList<Integer> bestCandidates;
  private ArrayList<PVector> lines;

  
  public houghCandidates(PImage edgeImg, int nbLines, int minVotes, int neighbourhoodSize){
    super(edgeImg);
    this.nbLines = nbLines;
    this.minVotes = minVotes;
    this.neighbourhoodSize = neighbourhoodSize;
    bestCandidates = new ArrayList<Integer>(nbLines);
    lines = new ArrayList<PVector>();
    
  }
  
  private ArrayList<Integer> bestCandidates(){
     return candidates();
  }
  
  public void drawEdges(){
     bestCandidates = bestCandidates();
     fillLines();
     for(int a=0; (a<lines.size()&&(a<nbLines)); ++a) {
     //  println("pool");
       // Pas de stress, les valeurs r et i stockées sont bel et bien des entiers, cf fillLines()
        int r = (int) lines.get(a).x;
        int i = (int) lines.get(a).y;
      
        // r = (x - centerX)*cos(phi) + (y-yc)*sin(phi) + houghHeight
        // x = 0 => y = ( r + centerX * cos(phi) - houghHeight)/ sin(phi) + centerY
        // y = 0 => x = ( r + centerY * sin(phi) - houghHeight)/ cos(phi) + centerY
        // x = img.width <=> x = 2*centerX
        // y = img.width <=> y = 2*centerY
        // Hence:
     
        int x0 = 0;
        int y0 = (int) ((r+ centerX* cosCache[i] - houghHeight)/sinCache[i] + centerY); //
        int x1 = (int) ((r + centerY*sinCache[i] - houghHeight)/ cosCache[i] + centerX);
        int y1 = 0;
        int x2 = img.width;
        int y2 = (int) ((r - centerX* cosCache[i] - houghHeight)/sinCache[i] + centerY);  //(-cos(phi) / sin(phi) *x2 + trueR/sin(phi));
        int y3 = img.width;
        int x3 = (int) ((r- houghHeight - centerY*sinCache[i])/ cosCache[i] + centerX);//(-(y3 - trueR/sin(phi)) * (sin(phi)/cos(phi)));
        //println("x0 : " + x0 + ", x1:" + x1 + ", x2 : "+ x2 + ", x3 : " + x3);
        //println("y0 : " + y0 + ", y1 : " + y1 + ", y2 :" + y2 + ", y3 : "+ y3);
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
  
  
  private void fillLines(){
    //println("s = " + bestCandidates.size());
    for(int a = 0; (a < bestCandidates.size() && a < nbLines); a++){
       int indx = bestCandidates.get(a); // gives something of the form i*doubleHeight + r
       int i = (int) Math.floor(indx/doubleHeight);
       int r = indx - i* doubleHeight;
       lines.add(new PVector(r,i));
    }
  }
  
  
  private ArrayList<Integer> candidates(){
    bestCandidates = new ArrayList<Integer>(nbLines);
    fillAccumulator();
    if(accumulatorEmpty()){
       println("buuuh");
       return bestCandidates;
    }
    
    // On cherche un maximum local maintenant!
    for(int i = 0; i < maxPhi; ++i){
      for(int r = neighbourhoodSize; r < doubleHeight - neighbourhoodSize; ++r){
        if(accumulator[i*doubleHeight + r] > minVotes){
          //  println("true!");
            //println("indice : " + i*doubleHeight + r);
            int max = accumulator[i*doubleHeight + r];
            
            // Si le point est bien un maximum local, on l'ajoute à notre tableau sous la forme de son indice dans l'accumulateur
            if(checkNeighbours(max,r,i,neighbourhoodSize)){ 
                  bestCandidates.add(i*doubleHeight +r);
            }
        }
      }
    }
     //println("b = " + bestCandidates.size());
    return sortCandidates(bestCandidates);
  }
  
  private ArrayList<Integer> sortCandidates(ArrayList<Integer> candidates){
       Collections.sort(candidates, new HoughComparator(accumulator));
       return candidates;
  }
  
  private boolean checkNeighbours(int value, int r, int phi, int neighbourhoodSize){
    for(int y = - neighbourhoodSize; y <= neighbourhoodSize; y++){
      for(int x = - neighbourhoodSize; x <= neighbourhoodSize; x++){
         int rPrime = r + x;
         int phiPrime = phi + y;
       //  println("phi orig : " + phi);
       //  println("dh : " + doubleHeight);
         
         // On doit penser à recentrer notre r', pour ne pas avoir de valeurs bizarres!
         /*if(rPrime < 0){
            rPrime += maxPhi; 
         } else if(rPrime > maxPhi){
            rPrime -= maxPhi; 
         }*/
         
         if(phiPrime < 0){
           phiPrime += maxPhi;
         } else if(phiPrime > maxPhi){
           phiPrime -= maxPhi; 
         }
         
     //    println("phi : " + phiPrime);
      //   println("r : " + rPrime);
       //  println("val : " + phiPrime*doubleHeight + rPrime);
         if(accumulator[phiPrime*doubleHeight + rPrime] > value){
            return false; 
         }
      }
    }
    return true;
  }
  
}