class houghCandidates extends houghTransform{
  final private int maxPhi= 180;
  
  // Le nombre de lignes est stocké dans un tableau
  private int nbLines, minVotes, neighbourhoodSize;
  
  private ArrayList<Integer> bestCandidates;
  private ArrayList<PVector> lines;
  private ArrayList<PVector> intersections;

  
  public houghCandidates(PImage edgeImg, int nbLines, int minVotes, int neighbourhoodSize){
    super(edgeImg);
    this.nbLines = nbLines;
    this.minVotes = minVotes;
    this.neighbourhoodSize = neighbourhoodSize;
    bestCandidates = new ArrayList<Integer>(nbLines);
    lines = new ArrayList<PVector>();
    intersections = new ArrayList<PVector>();
  }
  
  private ArrayList<Integer> bestCandidates(){
     return candidates();
  }
  
  public void updateAndDraw(PImage imageP){
     img = imageP;
     drawEdges();
     getIntersections(lines);
  }
  
  public ArrayList<PVector> createLines(){
     bestCandidates = bestCandidates();
     fillLines();
     return lines;
  }
  
  
  public void drawEdges(List<PVector> lines){
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
        int y0 = (int) ((r+ centerX* cosCache[i] - houghHeight)/sinCache[i] + centerY);
        int x1 = (int) ((r + centerY*sinCache[i] - houghHeight)/ cosCache[i] + centerX);
        int y1 = 0;
        int x2 = img.width;
        int y2 = (int) ((r - centerX* cosCache[i] - houghHeight)/sinCache[i] + centerY);
        int y3 = img.width;
        int x3 = (int) ((r- houghHeight - centerY*sinCache[i])/ cosCache[i] + centerX);
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
        int y0 = (int) ((r+ centerX* cosCache[i] - houghHeight)/sinCache[i] + centerY);
        int x1 = (int) ((r + centerY*sinCache[i] - houghHeight)/ cosCache[i] + centerX);
        int y1 = 0;
        int x2 = img.width;
        int y2 = (int) ((r - centerX* cosCache[i] - houghHeight)/sinCache[i] + centerY);
        int y3 = img.width;
        int x3 = (int) ((r- houghHeight - centerY*sinCache[i])/ cosCache[i] + centerX);
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
  
  public ArrayList<Integer> getCandidates(){
     return bestCandidates; 
  }
  
  public ArrayList<PVector> getLines(){
     return lines; 
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
  
  public ArrayList<PVector> getIntersections(List<PVector> lines) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to 'intersections'
        double d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
        int x = (int) (((line2.x)*sin(line1.y) - (line1.x)*sin(line2.y))/d);
        int y = (int) ((-(line2.x)*cos(line1.y) + (line1.x)*cos(line2.y))/d);
        intersections.add(new PVector(x, y));
        // draw the intersection
        fill(255, 128, 0);
        ellipse(x, y, 10, 10);
      }
    }
    return intersections;
  }
  
  public ArrayList<PVector> getIntersections(){
     return intersections; 
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