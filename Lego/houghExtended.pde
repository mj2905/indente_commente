class houghCandidates extends houghTransform {
  final private int maxPhi= 180;
  final private float discretizationStepsPhi = (float)Math.PI / maxPhi; 

  // Le nombre de lignes est stocké dans un tableau
  private int nbLines, minVotes, neighbourhoodSize;

  private ArrayList<Integer> bestCandidates;
  private ArrayList<PVector> lines;
  private ArrayList<PVector> intersections;
  private ArrayList<PVector> cartesianLines;

  public houghCandidates(PImage edgeImg, int nbLines, int minVotes, int neighbourhoodSize) {
    super(edgeImg);
    this.nbLines = nbLines;
    this.minVotes = minVotes;
    this.neighbourhoodSize = neighbourhoodSize;
    bestCandidates = new ArrayList<Integer>(nbLines);
    lines = new ArrayList<PVector>();
    intersections = new ArrayList<PVector>();
    cartesianLines = new ArrayList<PVector> ();
  }

  /*******************
   Méthodes externes
   ********************/

  /**
   Cette méthode prend en paramètre une PImage, pour remplacer l'image actuelle stockée.
   Elle met ensuite à jour les différents tableaux de lignes et intersections, en effectuant les calculs sur l'image nouvellement fournie.
   **/
  public void updateAndDraw(PImage imageP) {
    img = imageP;
    drawEdges();
    getIntersections(lines);
  }

  /**
   Cette méthode remplit le tableau des lignes après avoir trouvé les meilleurs candidats; elle retourne ensuite ce tableau.
   **/
  public ArrayList<PVector> createLines() {
    candidates();
    fillLines();
    return lines;
  }


  /**
   Cette méthode remplit le tableau des meilleurs candidats, puis celui des lignes ainsi filtrées.
   Elle calcule ensuite les différentes lignes à dessiner de la même façon que hough (excepté cette fois-ci que le nombre de votes est minVote et non plus 200 et qu'elle dessine au plus nbLines).
   Elle utilise pour le dessin addLine(), qui s'occupe à la fois de dessiner une ligne en lui donnant deux points, mais également de convertir ladite ligne en sa paramétrisation cartésienne et de l'ajouter à un tableau prévu à cet effet.
   Les coordonnées cartésiennes permettent en effet un calcul plus facile des intersections.
   **/
  public void drawEdges() {
    candidates();
    fillLines();
    for (int a=0; (a<lines.size()&&(a<nbLines)); ++a) {
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
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0) {
          addLine(x0, y0, x1, y1);
        } else if (y2 >0) {
          addLine(x0, y0, x2, y2);
        } else {
          addLine(x0, y0, x3, y3);
        }
      } else {
        if (x1>0) {
          if (y2 >0) {
            addLine(x1, y1, x2, y2);
          } else {
            addLine(x1, y1, x3, y3);
          }
        } else { 
          addLine(x2, y2, x3, y3);
        }
      }
    }
  }


  /**
   À partir des représentations cartésiennes, cette méthode contrôle les lignes deux à deux pour vérifier si elles possèdent un point d'intersection.
   Si tel est le cas, le point est ajouté à un tableau intersections.
   **/
  public ArrayList<PVector> getIntersections(List<PVector> lines) {
    ArrayList<PVector> intersections = new ArrayList<PVector>();
    for (int i = 0; i < cartesianLines.size() - 1; i++) {
      PVector line1 = cartesianLines.get(i);
      for (int j = i + 1; j < cartesianLines.size(); j++) {
        PVector line2 = cartesianLines.get(j);
        // compute the intersection and add it to 'intersections'
        float a1 = line1.x;
        float a2 = line2.x;
        float k1 = line1.y;
        float k2 = line2.y;

        if ((a1-a2) != 0) {
          float xC = -(k1-k2)/(a1-a2);
          //println("Intersection entre la ligne " + i + " et la ligne " + j + " donne x : " + xC);
          int x = (int) xC;
          float yC = a1*xC + k1;
          int y = (int) yC;
          intersections.add(new PVector(x, y));
          fill(255, 128, 0);
          ellipse(x, y, 10, 10);
        }
      }
    }
    return intersections;
  }



  /***********************
   Méthodes internes liées à l'algorithme de détection
   ************************/


  /**
   Prend en paramètre deux points,, (x0,y0) et (x1,y1) et:
   - dessine la ligne qui passe par ces deux points
   - ajoute au tableau cartesianLines la représentation cartésienne de cette ligne
   **/
  private void addLine(int x0, int y0, int x1, int y1) {
    line(x0, y0, x1, y1);
    //println("(x0, y0, x1, y1) = " + " ("+ x0 + ", "+ y0 + ", "+ x1 + ", " + y1 + ")"); 
    float coeff = (float)(y1-y0)/(x1-x0); // y = ax + b <=> b = y - ax
    float ordinate = y0 - coeff*x0;
    //println("coeff : " + coeff + "; ordinate : " + ordinate);
    cartesianLines.add(new PVector(coeff, ordinate));
  }

  /**
   s'occupe de remplir le tableau lines; une fois les lignes les plus "votées" trouvées dans l'accumulateur, il faut en extaire la paramétrisation polaire, et 
   la stocker sous forme d'un vecteur dans lines.
   C'est ce que fait fillLines().
   **/
  private void fillLines() {
    for (int a = 0; (a < bestCandidates.size() && a < nbLines); a++) {
      int indx = bestCandidates.get(a); // gives something of the form i*doubleHeight + r
      int i = (int) Math.floor(indx/doubleHeight);
      int r = indx - i* doubleHeight;
      lines.add(new PVector(r, i));
    }
  }


  /**
   Filtre les indices de l'accumulateur (ie: les paramétrisations de ligne polaires) qui sont des maxima locaux.
   Pour cela, la méthode va itérer sur différentes valeurs de l'accumulateur. Pour chaque point, à condition que le point possède assez de votes (>minVotes),
   elle vérifie dans un certain voisinage autour pour s'assurer qu'il s'agit bien d'un maximum local. Si oui, elle l'ajoute à un tableau temporaire.
   Une fois tous les maxima locaux localisés et ajoutés à ce tableau, ce dernier devient le tableau des meilleurs candidats, bestCandidates.
   Pour vérifier le voisinage, la méthode checkNeighbours est utilisée.
   **/
  private void candidates() {
    ArrayList newCandidates = new ArrayList<Integer>(nbLines);
    fillAccumulator();
    if (accumulatorEmpty()) {
      //println("buuuh");
      bestCandidates = newCandidates;
      return;
    }

    // On cherche un maximum local maintenant!
    for (int i = 0; i < maxPhi; ++i) {
      for (int r = neighbourhoodSize; r < doubleHeight - neighbourhoodSize; ++r) {
        if (accumulator[i*doubleHeight + r] > minVotes) {
          int max = accumulator[i*doubleHeight + r];

          // Si le point est bien un maximum local, on l'ajoute à notre tableau sous la forme de son indice dans l'accumulateur
          if (checkNeighbours(max, r, i, neighbourhoodSize)) { 
            newCandidates.add(i*doubleHeight +r);
          }
        }
      }
    }
    bestCandidates = sortCandidates(newCandidates);
  }

  /**
   Prend en paramètre une valeur (le maximum actuel), un couple (r, phi) ainsi qu'une taille de voisinage.
   Elle regarde ensuite dans le voisinage les points de l'accumulateur, vérifie que la valeur value est bien le maximum local.
   Renvoie true si c'est le cas, false sinon.
   **/
  private boolean checkNeighbours(int value, int r, int phi, int neighbourhoodSize) {
    for (int y = - neighbourhoodSize; y <= neighbourhoodSize; y++) {
      for (int x = - neighbourhoodSize; x <= neighbourhoodSize; x++) {
        int rPrime = r + x;
        int phiPrime = phi + y;

        // On doit penser à recentrer notre phi', pour ne pas avoir de valeurs bizarres!
        if (phiPrime < 0) {
          phiPrime += maxPhi;
        } else if (phiPrime > maxPhi) {
          phiPrime -= maxPhi;
        }

        //    println("phi : " + phiPrime);
        //   println("r : " + rPrime);
        //  println("val : " + phiPrime*doubleHeight + rPrime);
        if (accumulator[phiPrime*doubleHeight + rPrime] > value) {
          return false;
        }
      }
    }
    return true;
  }

  /**
   Trie le tableau passé en paramètre.
   **/
  private ArrayList<Integer> sortCandidates(ArrayList<Integer> candidates) {
    Collections.sort(candidates, new HoughComparator(accumulator));
    return candidates;
  }




  /*************
   Méthodes de getters
   ***************/

  public ArrayList<PVector> getCartesianLines() {
    return cartesianLines;
  }

  public ArrayList<Integer> getCandidates() {
    return bestCandidates;
  }

  public ArrayList<PVector> getLines() {
    return lines;
  } 

  public ArrayList<PVector> getIntersections() {
    return intersections;
  }
}