import java.util.*;

class HoughCorner {
  
  // size of the region we search for a local maximum
int neighbourhood;
// only search around lines with more that this amount of votes
// (to be adapted to your image)
  
  private houghTransform hough;
 
 private float discretizationStepsR = 2.5f;
 
 private int rDim = (int) (((img.width + img.height)*2 +1)/discretizationStepsR);
 
 
  private int minVotes;
  private int nLines;
  private ArrayList<Integer> bestCandidates;
  private ArrayList<PVector> edges;
  
  public HoughCorner(PImage edgeImg, int minvotes, int nlines, int neighbour) {
    hough= new houghTransform(edgeImg);
    minVotes=minvotes;
    nLines=nlines;
    //hough.fillAccumulator();
    neighbourhood=neighbour;
    bestCandidates=new ArrayList<Integer>();
    edges=new ArrayList<PVector>();
  }
  
  /*public void updateImage(PImage image) {
    this.hough.img=image;
  }*/
  
  public ArrayList<Integer> fillCandidates() {
    bestCandidates=new ArrayList<Integer>();
    hough.fillAccumulator();
    for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < hough.maxPhi; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (hough.accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          // check we are not outside the image
          if( accPhi+dPhi < 0 || accPhi+dPhi >= hough.maxPhi) continue;
          for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              // check we are not outside the image
                if(accR+dR < 0 || accR+dR >= rDim) continue;
                int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
                if(hough.accumulator[idx] < hough.accumulator[neighbourIdx]) {
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
    Collections.sort(bestCandidates, new HoughComparator(hough.accumulator));
    return bestCandidates;
  }
  
  public ArrayList<PVector> fillEdges() {
    edges=new ArrayList<PVector>();
    for(int i=0; (i<bestCandidates.size()&&(i<nLines)); ++i) {
      int idx=bestCandidates.get(i);
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * hough.discretizationStepsPhi;
      edges.add(new PVector(r, phi));
    }
    return edges;
  }
  
  public void drawEdges() {
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
      int x2 = img.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = img.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      stroke(204,102,0);
      if (y0 > 0) {
          if (x1 > 0)
            line(x0, y0, x1, y1);
          else if (y2 > 0)
            line(x0, y0, x2, y2);
          else
            line(x0, y0, x3, y3);
        }
      else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
          }
        else
          line(x2, y2, x3, y3);
        }
      }
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
  
  public void updateAndDraw(PImage img) {
    image(img, 0,0);
    
    
    hough= new houghTransform(img);
    //hough.fillAccumulator();
    fillCandidates();
    fillEdges();
    drawEdges();
    getIntersections(edges);
  }
}
      
      
      
   