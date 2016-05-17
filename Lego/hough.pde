class houghTransform {
  // Le nombre de valeurs que phi peut prendre
  final private int maxPhi= 180;

  // L'indice de palliers de phi et l'indice de palliers de R (pour passer d'un rayon continu à un rayon discret, on va devoir tronquer nos cases)
  final private float discretizationStepsPhi = (float)Math.PI / maxPhi; 

  // Respectivement l'image où l'on applique la transformation et l'image représentant l'accumulateur
  private PImage img;
  private PImage houghImg;

  // Les coordonnées du centre de l'image
  float centerX, centerY;

  // L'accumulateur, qui stocke une ligne (phi, r) à l'indice phi*rMax + r.
  int[] accumulator;

  // La hauteur de l'accumulateur
  int houghHeight;

  // On double la hauteur pour prendre les valeurs négatives en plus.
  int doubleHeight, width, height;

  // On stocke les valeurs de phi possibles, pour gagner des perf'
  double[] sinCache;
  double[] cosCache;

  private boolean accEmpty;

  public houghTransform(PImage edgeImg) {
    img = edgeImg;
    this.width = img.width;
    this.height = img.height;
    initialize();
  }

  /**
   Cette méthode initialise simplement la majorité des paramètres ainsi que les tableaux sinCache et cosCache, qui associent à un i une valeur de sin(i*discretizationStepsPhi),
   pour un gain de performance en économisant plus tard du temps de calcul.
   **/
  private void initialize() {
    houghHeight = (int) (Math.sqrt(2) * Math.max(height, width))/2;
    doubleHeight = 2*houghHeight;
    accumulator = new int[(maxPhi+2) * (doubleHeight +2 )];

    centerX = width /2 ;
    centerY = height/2;

    sinCache = new double[maxPhi];
    cosCache = sinCache.clone();
    for (int i = 0; i < maxPhi; i++) {
      double phi = i * discretizationStepsPhi;
      sinCache[i] = Math.sin(phi);
      cosCache[i] = Math.cos(phi);
    }
    accEmpty = true;
    houghImg = createImage(doubleHeight +2, maxPhi +2, ALPHA);
  }

  /***********
   Méthodes utilitaires internes
   **********/

  /**
   Méthode interne dont le but est d'incrémenter l'accumulateur.
   On incrémente sur toutes les valeurs possibles de phi; à partir de ce dernier, puisque x et y sont connus, on détermine r (en le recentrant de façon appropriée), puis on incrémente
   la position (r, phi) de l'accumulateur de 1, pour chaque r et phi associés à x et y.
   **/
  private void addPoint(int x, int y) {
    int r = 0;
    for (int i = 0; i <maxPhi; i++) {
      r = (int) (((x - centerX) * cosCache[i]) + ((y-centerY) * sinCache[i]));
      r += (doubleHeight-1)/2;
      if (r < 0 || r > doubleHeight) continue;
      accEmpty = false;
      accumulator[i * doubleHeight + r] += 1;
    }
  }


  /*********
   Méthodes liées à hough
   *********/

  /**
   Cette méthode remplit l'accumulateur selon le système de votes.
   Pour cela, elle ne s'intéresse qu'aux points blancs. À chaque point blanc rencontré de la sorte, on incrémente l'une des positions de l'accumulateur de 1, pour toutes les lignes pouvant passer par ce point.
   (Cette incrémentation est en fait réalisée dans la méthode addPoint)
   **/
  public void fillAccumulator() {
    //accumulator = new int[(maxPhi+2) * (doubleHeight +2 )];
    img.loadPixels();
    accumulator = new int[(maxPhi+2) * (doubleHeight +2 )];
    accEmpty = true;
    for (int y = 0; y < img.height; ++y) {
      for (int x = 0; x < img.width; ++x) {
        if (brightness(img.pixels[y*img.width + x]) != 0) {
          addPoint(x, y);
        }
      }
    }
    img.updatePixels();
  }

  /**
   Cette méthode met à jour la représentation de l'accumulateur en tant qu'image, d'où son nom.
   **/
  public PImage pictureOfAccumulator() {
    houghImg.loadPixels();
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }

    //houghImg.resize(800, 600);
    houghImg.updatePixels();
    return houghImg;
  }

  /**
   Une simple méthode booléenne qui indique si l'accumulateur est vide ou non.
   **/
  public boolean accumulatorEmpty() {
    return accEmpty;
  }


  /**
   Cette méthode s'occupe de parcourir l'accumulateur pour y trouver les lignes qui présentent un intérêt pour nous, ie celles qui ont reçu 200 ou plus votes.
   De la paramétrisation (r, phi), on peut ensuite déduire la ligne, et la tracer de façon appropriée sur l'image; d'où le nom.
   **/
  public void drawLines() {
    for (int i = 0; i < maxPhi; ++i) {
      for (int r = 0; r < doubleHeight; ++r) {
        // On filtre uniquement les valeurs qui ont reçu assez de votes dans l'accumulateur (ici 200) 

        if (accumulator[i*doubleHeight +r] > 200) {
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
    }
  }


  /***********
   Méthodes à utilisation externe: getters et setters
   ***********/


  public int[] getAccumulator() {
    return accumulator;
  }

  public void setImage(PImage secondImg) {
    this.img = secondImg;
  }

  public float getCenterX() {
    return centerX;
  }

  public float getCenterY() {
    return centerY;
  }
}