import java.util.*;

class HoughCorner {
  
  // size of the region we search for a local maximum
int neighbourhood;
// only search around lines with more that this amount of votes
// (to be adapted to your image)
  
  private HoughAlgorithm hough;
 
 
  private int minVotes;
  private int nLines;
  
  public HoughCorner(PImage edgeImg, int minvotes, int nlines, int neighbour) {
    hough= new HoughAlgorithm(edgeImg);
    minVotes=minvotes;
    nLines=nlines;
    //hough.fillAccumulator();
    neighbourhood=neighbour;
  }
  
  /*public void updateImage(PImage image) {
    this.hough.img=image;
  }*/
  
  private List<Integer> candidatesBuffer;
  private boolean candidatesBufferCreates = false;
  
  private List<Integer> bestCandidates() {
    if(!candidatesBufferCreates) {
       candidatesBuffer = fillCandidates(hough.getAccumulator());
    }
    candidatesBufferCreates = true;
    return candidatesBuffer;
  }
  
  private List<Integer> fillCandidates(int[] accumulator) {
    List<Integer> bestCandidates=new ArrayList<Integer>();
    for (int accR = 0; accR < hough.rDim; accR++) {
    for (int accPhi = 0; accPhi < hough.phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (hough.rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= hough.phiDim) continue;
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
                if(accR+dR < 0 || accR+dR >= hough.rDim) continue;
                int neighbourIdx = (accPhi + dPhi + 1) * (hough.rDim + 2) + accR + dR + 1;
                if(accumulator[idx] < accumulator[neighbourIdx]) {
                  // the current idx is not a local maximum!
                  bestCandidate=false;
                  break;
              }
            }
            if(!bestCandidate) break;
          }
          if(bestCandidate) {
            // the current idx *is* a local maximum
            bestCandidates.add(idx);
          }
        }
      }
    }
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    return bestCandidates;
  }
  
  private List<PVector> getEdges(List<Integer> bestCandidates) {
    List<PVector> edges = new ArrayList<PVector>();
    for(int i=0; (i<bestCandidates.size()&&(i<nLines)); ++i) {
      int idx=bestCandidates.get(i);
      int accPhi = (int) (idx / (hough.rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (hough.rDim + 2) - 1;
      float r = (accR - (hough.rDim - 1) * 0.5f) * hough.discretizationStepsR;
      float phi = accPhi * hough.discretizationStepsPhi;
      edges.add(new PVector(r, phi));
    }
    return edges;
  }
  
  private void drawEdges(PGraphics image, List<PVector> edges) {
    for(int i=0; (i<edges.size()&&(i<nLines)); ++i) {
      float r = edges.get(i).x;
      float phi = edges.get(i).y;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = image.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = image.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      image.stroke(204,102,0);
      if (y0 > 0) {
          if (x1 > 0)
            image.line(x0, y0, x1, y1);
          else if (y2 > 0)
            image.line(x0, y0, x2, y2);
          else
            image.line(x0, y0, x3, y3);
        }
      else {
        if (x1 > 0) {
          if (y2 > 0)
            image.line(x1, y1, x2, y2);
          else
            image.line(x1, y1, x3, y3);
          }
        else
          image.line(x2, y2, x3, y3);
        }
      }
  }
  
  public List<PVector> getIntersections(List<PVector> lines) {
    List<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < lines.size() - 1; i++) {
      PVector line1 = lines.get(i);
      for (int j = i + 1; j < lines.size(); j++) {
        PVector line2 = lines.get(j);
        // compute the intersection and add it to 'intersections'
        double d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
        int x = (int) (((line2.x)*sin(line1.y) - (line1.x)*sin(line2.y))/d);
        int y = (int) ((-(line2.x)*cos(line1.y) + (line1.x)*cos(line2.y))/d);
        intersections.add(new PVector(x, y, 1));
      }
    }
    return intersections;
  }
  
  private void drawIntersections(PGraphics image, List<PVector> intersections) {
    image.fill(255, 128, 0); 
    for (int i = 0; i < intersections.size(); i++) {
        PVector point = intersections.get(i);
        // draw the intersection
        image.ellipse(point.x, point.y, 10, 10);
    }
  }
  
  public PImage getHough() {
   return hough.getHough(hough.getAccumulator());
  }
  
  public List<PVector> getBestEdges() {return getEdges(bestCandidates());}
  public List<PVector> getBestIntersections() {return getIntersections(getBestEdges());}
}
      
      
      
   