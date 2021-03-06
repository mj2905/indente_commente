import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ArrayList;

class QuadGraph {


  List<int[]> cycles = new ArrayList<int[]>();
  int[][] graph;

  void build(List<PVector> lines, int width, int height) {

    int n = lines.size();

    // The maximum possible number of edges is n * (n - 1)/2
    graph = new int[n * (n - 1)/2][2];

    int idx =0;

    for (int i = 0; i < lines.size(); i++) {
      for (int j = i + 1; j < lines.size(); j++) {
        if (intersect(lines.get(i), lines.get(j), width, height)) {

          // TODO
          // fill the graph using intersect() to check if two lines are
          // connected in the graph.
          
          graph[idx][0] = i;
          graph[idx][1] = j;

          idx++;
        }
      }
    }
  }

  /** Returns true if polar lines 1 and 2 intersect 
   * inside an area of size (width, height)
   */
  boolean intersect(PVector line1, PVector line2, int width, int height) {

    double sin_t1 = Math.sin(line1.y);
    double sin_t2 = Math.sin(line2.y);
    double cos_t1 = Math.cos(line1.y);
    double cos_t2 = Math.cos(line2.y);
    float r1 = line1.x;
    float r2 = line2.x;

    double denom = cos_t2 * sin_t1 - cos_t1 * sin_t2;

    int x = (int) ((r2 * sin_t1 - r1 * sin_t2) / denom);
    int y = (int) ((-r2 * cos_t1 + r1 * cos_t2) / denom);

    if (0 <= x && 0 <= y && width >= x && height >= y)
      return true;
    else
      return false;
  }
  
  PVector intersection(PVector line1, PVector line2) {

    double sin_t1 = Math.sin(line1.y);
    double sin_t2 = Math.sin(line2.y);
    double cos_t1 = Math.cos(line1.y);
    double cos_t2 = Math.cos(line2.y);
    float r1 = line1.x;
    float r2 = line2.x;

    double denom = cos_t2 * sin_t1 - cos_t1 * sin_t2;

    int x = (int) ((r2 * sin_t1 - r1 * sin_t2) / denom);
    int y = (int) ((-r2 * cos_t1 + r1 * cos_t2) / denom);

    return new PVector(x,y,1);
  }
  
  Set<PVector> bestCyclesNodes(List<PVector> lines, float max_area, float min_area) {
    
    List<int[]> cycles = findCycles();
    Set<PVector> nodesFromBestCycles = new HashSet();
    
    float biggestAreaFound = 0;
    
    for(int i = 0; i < cycles.size(); ++i) {
      //println("cycle");
      
      PVector l0 = lines.get(cycles.get(i)[0]);
      PVector l1 = lines.get(cycles.get(i)[1]);
      PVector l2 = lines.get(cycles.get(i)[2]);
      PVector l3 = lines.get(cycles.get(i)[3]);
      
      PVector i0 = intersection(l0, l1);
      PVector i1 = intersection(l1,l2);
      PVector i2 = intersection(l2,l3);
      PVector i3 = intersection(l3,l0);

      float area = area(i0,i1,i2,i3);
      if(area > biggestAreaFound) {
        if(isConvex(i0, i1, i2, i3)
          && validArea(i0, i1, i2, i3, max_area, min_area)
          //&& nonFlatQuad(i0, i1, i2, i3)
          ){
          nodesFromBestCycles.clear();
          nodesFromBestCycles.add(i0);
          nodesFromBestCycles.add(i1);
          nodesFromBestCycles.add(i2);
          nodesFromBestCycles.add(i3);
          biggestAreaFound = area; 
        }
      }
      
    }
    
    return nodesFromBestCycles;
  }
  
  Set<PVector> bestCycles(List<PVector> lines, float max_area, float min_area) {
    
    List<int[]> cycles = findCycles();
    Set<PVector> linesFromBestCycles = new HashSet();
    
    float biggestAreaFound = 0;
    
    for(int i = 0; i < cycles.size(); ++i) {
      //println("cycle");
      
      PVector l0 = lines.get(cycles.get(i)[0]);
      PVector l1 = lines.get(cycles.get(i)[1]);
      PVector l2 = lines.get(cycles.get(i)[2]);
      PVector l3 = lines.get(cycles.get(i)[3]);
      
      PVector i0 = intersection(l0, l1);
      PVector i1 = intersection(l1,l2);
      PVector i2 = intersection(l2,l3);
      PVector i3 = intersection(l3,l0);

      float area = area(i0,i1,i2,i3);
      if(area > biggestAreaFound) {
        if(isConvex(i0, i1, i2, i3)
          && validArea(i0, i1, i2, i3, max_area, min_area)
          //&& nonFlatQuad(i0, i1, i2, i3)
          ){
          linesFromBestCycles.clear();
          linesFromBestCycles.add(l0);
          linesFromBestCycles.add(l1);
          linesFromBestCycles.add(l2);
          linesFromBestCycles.add(l3);
          biggestAreaFound = area; 
        }
      }
      
    }
    
    return linesFromBestCycles;
  }

  List<int[]> findCycles() {

    cycles.clear();
    for (int i = 0; i < graph.length; i++) {
      for (int j = 0; j < graph[i].length; j++) {
        findNewCycles(new int[] {graph[i][j]});
      }
    }
    /*
    for (int[] cy : cycles) {
      String s = "" + cy[0];
      for (int i = 1; i < cy.length; i++) {
        s += "," + cy[i];
      }
      System.out.println(s);
    }
    */
    return cycles;
  }
  /*
  void test(List<int[]> quads) {
    for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
      // (intersection() is a simplified version of the
      // intersections() method you wrote last week, that simply
      // return the coordinates of the intersection between 2 lines)
      PVector c12 = intersection(l1, l2);
      PVector c23 = intersection(l2, l3);
      PVector c34 = intersection(l3, l4);
      PVector c41 = intersection(l4, l1);
      // Choose a random, semi-transparent colour
      Random random = new Random();
      fill(color(min(255, random.nextInt(300)),
      min(255, random.nextInt(300)),
      min(255, random.nextInt(300)), 50));
      quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
    }
  }
  */
  void findNewCycles(int[] path)
  {
    int n = path[0];
    int x;
    int[] sub = new int[path.length + 1];

    for (int i = 0; i < graph.length; i++)
      for (int y = 0; y <= 1; y++)
        if (graph[i][y] == n)
          //  edge refers to our current node
        {
          x = graph[i][(y + 1) % 2];
          if (!visited(x, path))
            //  neighbor node not on path yet
          {
            sub[0] = x;
            System.arraycopy(path, 0, sub, 1, path.length);
            //  explore extended path
            findNewCycles(sub);
          } else if ((path.length == 4) && (x == path[path.length - 1]))
            //  cycle found
          {
            int[] p = normalize(path);
            int[] inv = invert(p);
            if (isNew(p) && isNew(inv))
            {
              cycles.add(p);
            }
          }
        }
  }
  
  

  //  check of both arrays have same lengths and contents
  Boolean equals(int[] a, int[] b)
  {
    Boolean ret = (a[0] == b[0]) && (a.length == b.length);

    for (int i = 1; ret && (i < a.length); i++)
    {
      if (a[i] != b[i])
      {
        ret = false;
      }
    }

    return ret;
  }

  //  create a path array with reversed order
  int[] invert(int[] path)
  {
    int[] p = new int[path.length];

    for (int i = 0; i < path.length; i++)
    {
      p[i] = path[path.length - 1 - i];
    }

    return normalize(p);
  }

  //  rotate cycle path such that it begins with the smallest node
  int[] normalize(int[] path)
  {
    int[] p = new int[path.length];
    int x = smallest(path);
    int n;

    System.arraycopy(path, 0, p, 0, path.length);

    while (p[0] != x)
    {
      n = p[0];
      System.arraycopy(p, 1, p, 0, p.length - 1);
      p[p.length - 1] = n;
    }

    return p;
  }

  //  compare path against known cycles
  //  return true, iff path is not a known cycle
  Boolean isNew(int[] path)
  {
    Boolean ret = true;

    for (int[] p : cycles)
    {
      if (equals(p, path))
      {
        ret = false;
        break;
      }
    }

    return ret;
  }

  //  return the int of the array which is the smallest
  int smallest(int[] path)
  {
    int min = path[0];

    for (int p : path)
    {
      if (p < min)
      {
        min = p;
      }
    }

    return min;
  }

  //  check if vertex n is contained in path
  Boolean visited(int n, int[] path)
  {
    Boolean ret = false;

    for (int p : path)
    {
      if (p == n)
      {
        ret = true;
        break;
      }
    }

    return ret;
  }



  /** Check if a quad is convex or not.
   * 
   * Algo: take two adjacent edges and compute their cross-product. 
   * The sign of the z-component of all the cross-products is the 
   * same for a convex polygon.
   * 
   * See http://debian.fmi.uni-sofia.bg/~sergei/cgsr/docs/clockwise.htm
   * for justification.
   * 
   * @param c1
   */
  boolean isConvex(PVector c1, PVector c2, PVector c3, PVector c4) {

    PVector v21= PVector.sub(c1, c2);
    PVector v32= PVector.sub(c2, c3);
    PVector v43= PVector.sub(c3, c4);
    PVector v14= PVector.sub(c4, c1);

    float i1=v21.cross(v32).z;
    float i2=v32.cross(v43).z;
    float i3=v43.cross(v14).z;
    float i4=v14.cross(v21).z;

    if (   (i1>0 && i2>0 && i3>0 && i4>0) 
      || (i1<0 && i2<0 && i3<0 && i4<0))
      return true;
    else 
    //System.out.println("Eliminating non-convex quad");
    return false;
  }

  /** Compute the area of a quad, and check it lays within a specific range
   */
  boolean validArea(PVector c1, PVector c2, PVector c3, PVector c4, float max_area, float min_area) {

    PVector v21= PVector.sub(c1, c2);
    PVector v32= PVector.sub(c2, c3);
    PVector v43= PVector.sub(c3, c4);
    PVector v14= PVector.sub(c4, c1);

    float i1=v21.cross(v32).z;
    float i2=v32.cross(v43).z;
    float i3=v43.cross(v14).z;
    float i4=v14.cross(v21).z;

    float area = Math.abs(0.5f * (i1 + i2 + i3 + i4));

    //System.out.println(area);

    boolean valid = (area < max_area && area > min_area);

    //if (!valid) System.out.println("Area out of range");

    return valid;
  }
  
  float area(PVector c1, PVector c2, PVector c3, PVector c4) {

    PVector v21= PVector.sub(c1, c2);
    PVector v32= PVector.sub(c2, c3);
    PVector v43= PVector.sub(c3, c4);
    PVector v14= PVector.sub(c4, c1);

    float i1=v21.cross(v32).z;
    float i2=v32.cross(v43).z;
    float i3=v43.cross(v14).z;
    float i4=v14.cross(v21).z;

    return Math.abs(0.5f * (i1 + i2 + i3 + i4));
  }

  /** Compute the (cosine) of the four angles of the quad, and check they are all large enough
   * (the quad representing our board should be close to a rectangle)
   */
  boolean nonFlatQuad(PVector c1, PVector c2, PVector c3, PVector c4) {

    // cos(70deg) ~= 0.3
    float min_cos = 0.5f;

    PVector v21= PVector.sub(c1, c2);
    PVector v32= PVector.sub(c2, c3);
    PVector v43= PVector.sub(c3, c4);
    PVector v14= PVector.sub(c4, c1);

    float cos1=Math.abs(v21.dot(v32) / (v21.mag() * v32.mag()));
    float cos2=Math.abs(v32.dot(v43) / (v32.mag() * v43.mag()));
    float cos3=Math.abs(v43.dot(v14) / (v43.mag() * v14.mag()));
    float cos4=Math.abs(v14.dot(v21) / (v14.mag() * v21.mag()));

    if (cos1 < min_cos && cos2 < min_cos && cos3 < min_cos && cos4 < min_cos)
      return true;
    else {
      //System.out.println("Flat quad");
      return false;
    }
  }
}